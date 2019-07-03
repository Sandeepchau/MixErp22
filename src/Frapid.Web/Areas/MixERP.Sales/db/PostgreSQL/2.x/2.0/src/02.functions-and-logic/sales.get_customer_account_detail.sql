DROP FUNCTION IF EXISTS sales.get_customer_account_detail(integer, date, date, integer);
CREATE OR REPLACE FUNCTION sales.get_customer_account_detail
(
    _customer_id        integer,
    _from               date,
    _to                 date,
    _office_id          integer
)
RETURNS TABLE
(
    id                      integer, 
    value_date              date, 
    book_date               date,
    tran_id                 bigint,
    tran_code               text,
    invoice_number          bigint, 
    tran_type               text, 
    debit                   numeric(30, 6), 
    credit                  numeric(30, 6), 
    balance                 numeric(30, 6)
)
AS
$BODY$
BEGIN
    CREATE TEMPORARY TABLE _customer_account_detail
    (
        id                      SERIAL NOT NULL,
        value_date              date,
        book_date               date,
        tran_id                 bigint,
        tran_code               text,
        invoice_number          bigint,
        tran_type               text,
        debit                   numeric(30, 6),
        credit                  numeric(30, 6),
        balance                 numeric(30, 6)
    ) ON COMMIT DROP;

    INSERT INTO _customer_account_detail
    (
        value_date, 
        book_date,
        tran_id,
        tran_code,
        invoice_number, 
        tran_type, 
        debit, 
        credit
    )
    SELECT 
        customer_transaction_view.value_date,
        customer_transaction_view.book_date,
        customer_transaction_view.transaction_master_id,
        customer_transaction_view.transaction_code,
        customer_transaction_view.invoice_number,
        customer_transaction_view.statement_reference,
        customer_transaction_view.debit,
        customer_transaction_view.credit
    FROM sales.customer_transaction_view
    LEFT JOIN inventory.customers
    ON customer_transaction_view.customer_id = customers.customer_id
    LEFT JOIN sales.sales_view
    ON sales_view.invoice_number = customer_transaction_view.invoice_number
    WHERE customer_transaction_view.customer_id = _customer_id
    AND NOT customers.deleted
	AND sales_view.office_id = _office_id
    AND customer_transaction_view.value_date BETWEEN _from AND _to;

    UPDATE _customer_account_detail 
    SET balance = c.balance
    FROM
    (
        SELECT p.id,
            SUM(COALESCE(c.debit, 0) - COALESCE(c.credit, 0)) As balance
        FROM _customer_account_detail p
        LEFT JOIN _customer_account_detail c
        ON c.id <= p.id
        GROUP BY p.id
        ORDER BY p.id
    ) AS c
    WHERE _customer_account_detail.id = c.id;

    RETURN QUERY
    SELECT * FROM _customer_account_detail;
END
$BODY$
 LANGUAGE plpgsql;


--select * from sales.get_customer_account_detail(1, '1-1-2000', '1-1-2060', 1);