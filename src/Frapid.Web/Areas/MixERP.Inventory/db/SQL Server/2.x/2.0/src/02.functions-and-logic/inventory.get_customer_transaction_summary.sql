IF OBJECT_ID('inventory.get_customer_transaction_summary') IS NOT NULL
DROP FUNCTION inventory.get_customer_transaction_summary;

GO

CREATE FUNCTION inventory.get_customer_transaction_summary
(
    @office_id                  integer, 
    @customer_id				integer
)
RETURNS @results TABLE
(
    currency_code               national character varying(12), 
    currency_symbol             national character varying(12), 
    total_due_amount            numeric(30, 6), 
    office_due_amount           numeric(30, 6)
)
AS
BEGIN
    DECLARE @root_office_id		integer = 0;
    DECLARE @currency_code		national character varying(12); 
    DECLARE @currency_symbol    national character varying(12);
    DECLARE @total_due_amount   numeric(30, 6); 
    DECLARE @office_due_amount  numeric(30, 6); 
    DECLARE @last_receipt_date  date;
    DECLARE @transaction_value  numeric(30, 6);

    SET @currency_code = inventory.get_currency_code_by_customer_id(@customer_id);

    SELECT @currency_symbol = core.currencies.currency_symbol 
    FROM core.currencies
    WHERE core.currencies.currency_code = @currency_code;

    SELECT @root_office_id = core.offices.office_id
    FROM core.offices
    WHERE parent_office_id IS NULL;

    SET @total_due_amount = inventory.get_total_customer_due(@root_office_id, @customer_id);
    SET @office_due_amount = inventory.get_total_customer_due(@office_id, @customer_id);
	
	INSERT INTO @results
    SELECT @currency_code, @currency_symbol, @total_due_amount, @office_due_amount;
	
	RETURN;
END

GO

--SELECT * FROM inventory.get_customer_transaction_summary(1, 1);
