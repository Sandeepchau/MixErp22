DROP FUNCTION IF EXISTS sales.get_gift_card_balance(_gift_card_id integer, _value_date date);

CREATE FUNCTION sales.get_gift_card_balance(_gift_card_id integer, _value_date date)
RETURNS numeric(30, 6)
AS
$$
    DECLARE _debit          numeric(30, 6);
    DECLARE _credit         numeric(30, 6);
BEGIN
    SELECT SUM(COALESCE(sales.gift_card_transactions.amount, 0))
    INTO _debit
    FROM sales.gift_card_transactions
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.gift_card_transactions.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND sales.gift_card_transactions.transaction_type = 'Dr'
    AND finance.transaction_master.value_date <= _value_date;

    SELECT SUM(COALESCE(sales.gift_card_transactions.amount, 0))
    INTO _credit
    FROM sales.gift_card_transactions
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.gift_card_transactions.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND sales.gift_card_transactions.transaction_type = 'Cr'
    AND finance.transaction_master.value_date <= _value_date;

    --Gift cards are account payables
    RETURN COALESCE(_credit, 0) - COALESCE(_debit, 0);
END
$$
LANGUAGE plpgsql;