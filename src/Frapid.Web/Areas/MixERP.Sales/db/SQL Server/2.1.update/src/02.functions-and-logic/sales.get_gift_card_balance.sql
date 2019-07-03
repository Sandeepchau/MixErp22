IF OBJECT_ID('sales.get_gift_card_balance') IS NOT NULL
DROP FUNCTION sales.get_gift_card_balance;

GO

CREATE FUNCTION sales.get_gift_card_balance(@gift_card_id integer, @value_date date)
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @debit          numeric(30, 6);
    DECLARE @credit         numeric(30, 6);

    SELECT @debit = SUM(COALESCE(sales.gift_card_transactions.amount, 0))
    FROM sales.gift_card_transactions
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.gift_card_transactions.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND sales.gift_card_transactions.transaction_type = 'Dr'
    AND finance.transaction_master.value_date <= @value_date;

    SELECT @credit = SUM(COALESCE(sales.gift_card_transactions.amount, 0))
    FROM sales.gift_card_transactions
    INNER JOIN finance.transaction_master
    ON finance.transaction_master.transaction_master_id = sales.gift_card_transactions.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND sales.gift_card_transactions.transaction_type = 'Cr'
    AND finance.transaction_master.value_date <= @value_date;

    --Gift cards are account payables
    RETURN COALESCE(@credit, 0) - COALESCE(@debit, 0);
END



GO
