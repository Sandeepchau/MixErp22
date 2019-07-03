DROP FUNCTION IF EXISTS sales.get_gift_card_detail(national character varying(50), date, date, integer);
CREATE FUNCTION sales.get_gift_card_detail
(
    _card_number        national character varying(50),
    _from               date,
    _to                 date,
    _office_id          integer
)
RETURNS TABLE
(
    id                  integer, 
    gift_card_id        integer, 
    transaction_ts      timestamp without time zone, 
    statement_reference text, 
    debit               numeric(30,6), 
    credit              numeric(30,6), 
    balance             numeric(30,6)
)
AS
$BODY$
BEGIN
    CREATE TEMPORARY TABLE  _gift_card_detail
    (
        id                      SERIAL NOT NULL,    
        gift_card_id            integer,
        transaction_ts          timestamp without time zone, 
        statement_reference     text,
        debit                   numeric(30, 6),
        credit                  numeric(30, 6),
        balance                 numeric(30, 6)
    ) ON COMMIT DROP;

    INSERT INTO _gift_card_detail
    (
        gift_card_id, 
        transaction_ts, 
        statement_reference, 
        debit, 
        credit
    )
    SELECT 
        t.gift_card_id, 
        t.transaction_ts, 
        t.statement_reference, 
        t.debit, 
        t.credit
    FROM
    (
        SELECT  gift_card_transactions.gift_card_id,
                transaction_master.transaction_ts,
                transaction_master.statement_reference,
                CASE WHEN gift_card_transactions.transaction_type = 'Dr' THEN gift_card_transactions.amount END AS debit,
                CASE WHEN gift_card_transactions.transaction_type = 'Cr' THEN gift_card_transactions.amount END AS credit
        FROM sales.gift_card_transactions
        JOIN finance.transaction_master
            ON transaction_master.transaction_master_id = gift_card_transactions.transaction_master_id
        JOIN sales.gift_cards
            ON gift_cards.gift_card_id = gift_card_transactions.gift_card_id
        WHERE gift_cards.gift_card_number = _card_number
        AND transaction_master.verification_status_id > 0
        AND NOT transaction_master.deleted
		AND transaction_master.office_id IN (SELECT get_office_ids FROM core.get_office_ids(_office_id))
        AND transaction_master.transaction_ts::date BETWEEN _from AND _to
        UNION ALL
        
        SELECT 
            sales.gift_card_id,
            transaction_master.transaction_ts,
            transaction_master.statement_reference,
            sales.total_amount,
            0
            FROM sales.sales
            LEFT JOIN finance.transaction_master
            ON transaction_master.transaction_master_id = sales.transaction_master_id
            JOIN sales.gift_cards
            ON gift_cards.gift_card_id = sales.gift_card_id
            WHERE sales.gift_card_id IS NOT NULL
            AND gift_cards.gift_card_number = _card_number
            AND transaction_master.verification_status_id > 0
            AND NOT transaction_master.deleted
            AND transaction_master.office_id IN (SELECT get_office_ids FROM core.get_office_ids(_office_id))
            AND transaction_master.transaction_ts::date BETWEEN _from AND _to
        ) t
        ORDER BY t.transaction_ts ASC;

    UPDATE _gift_card_detail
    SET balance = c.balance
    FROM
    (
        SELECT
            p.id, 
            SUM(COALESCE(c.credit, 0) - COALESCE(c.debit, 0)) As balance
        FROM _gift_card_detail p
        LEFT JOIN _gift_card_detail AS c 
            ON (c.transaction_ts <= p.transaction_ts)
        GROUP BY p.id
        ORDER BY p.id    
     ) AS c
    WHERE _gift_card_detail.id = c.id;
    
    RETURN QUERY
    (
        SELECT * FROM _gift_card_detail
        ORDER BY transaction_ts ASC
    );
END
$BODY$
  LANGUAGE plpgsql;

