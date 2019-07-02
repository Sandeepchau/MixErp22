IF OBJECT_ID('inventory.get_total_supplier_due') IS NOT NULL
DROP FUNCTION inventory.get_total_supplier_due;

GO

CREATE FUNCTION inventory.get_total_supplier_due(@office_id integer, @supplier_id integer)
RETURNS DECIMAL(24, 4)
AS
BEGIN
    DECLARE @account_id                     integer							= inventory.get_account_id_by_supplier_id(@supplier_id);
    DECLARE @debit                          numeric(30, 6)					= 0;
    DECLARE @credit                         numeric(30, 6)					= 0;
    DECLARE @local_currency_code            national character varying(12)	= core.get_currency_code_by_office_id(@office_id); 
    DECLARE @base_currency_code             national character varying(12)	= inventory.get_currency_code_by_supplier_id(@supplier_id);
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
    SET @amount_in_local_currency	= COALESCE(@credit, 0) - COALESCE(@debit, 0);


    SET @amount_in_base_currency	= @amount_in_local_currency * @er; 

    RETURN @amount_in_base_currency;
END

GO

--SELECT inventory.get_total_supplier_due(1, 1);
--SELECT inventory.get_total_supplier_due(1, 13)

--select inventory.get_account_id_by_supplier_id(13)

--select * from finance.accounts
--where account_id = 297

--select * FROM finance.verified_transaction_view


--SELECT SUM(amount_in_local_currency)
--FROM finance.verified_transaction_view
--WHERE finance.verified_transaction_view.account_id IN (SELECT * FROM finance.get_account_ids(297))
--AND finance.verified_transaction_view.office_id IN (SELECT * FROM core.get_office_ids(1))
--AND tran_type='Cr';
