IF OBJECT_ID('inventory.get_total_customer_due') IS NOT NULL
DROP FUNCTION inventory.get_total_customer_due;

GO

CREATE FUNCTION inventory.get_total_customer_due(@office_id integer, @customer_id integer)
RETURNS DECIMAL(24, 4)
AS
BEGIN
    DECLARE @account_id                     integer							= inventory.get_account_id_by_customer_id(@customer_id);
    DECLARE @debit                          numeric(30, 6)					= 0;
    DECLARE @credit                         numeric(30, 6)					= 0;
    DECLARE @local_currency_code            national character varying(12)	= core.get_currency_code_by_office_id(@office_id); 
    DECLARE @base_currency_code             national character varying(12)	= inventory.get_currency_code_by_customer_id(@customer_id);
    DECLARE @amount_in_local_currency       numeric(30, 6)					= 0;
    DECLARE @amount_in_base_currency        numeric(30, 6)					= 0;
    DECLARE @er								numeric(30, 6)					= 0;

    SELECT @debit = SUM(amount_in_local_currency)
    FROM finance.verified_transaction_view
    WHERE finance.verified_transaction_view.account_id IN (SELECT * FROM finance.get_account_ids(@account_id))
    AND finance.verified_transaction_view.office_id IN (SELECT * FROM core.get_office_ids(@office_id))
    AND tran_type='Dr';

    SELECT @credit = SUM(amount_in_local_currency)
    FROM finance.verified_transaction_view
    WHERE finance.verified_transaction_view.account_id IN (SELECT * FROM finance.get_account_ids(@account_id))
    AND finance.verified_transaction_view.office_id IN (SELECT * FROM core.get_office_ids(@office_id))
    AND tran_type='Cr';

    SET @er							= COALESCE(finance.convert_exchange_rate(@office_id, @local_currency_code, @base_currency_code), 0);
    SET @amount_in_local_currency	= COALESCE(@debit, 0) - COALESCE(@credit, 0);


    SET @amount_in_base_currency	= @amount_in_local_currency * @er; 

    RETURN @amount_in_base_currency;
END

GO

--SELECT inventory.get_total_customer_due(1, 1);
