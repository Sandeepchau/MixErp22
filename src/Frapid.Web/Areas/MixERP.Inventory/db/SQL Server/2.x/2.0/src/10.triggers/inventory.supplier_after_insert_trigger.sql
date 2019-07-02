IF OBJECT_ID('inventory.supplier_after_insert_trigger') IS NOT NULL
DROP TRIGGER inventory.supplier_after_insert_trigger;

GO

CREATE TRIGGER inventory.supplier_after_insert_trigger
ON inventory.suppliers
AFTER INSERT
AS
BEGIN    
	DECLARE @supplier_type_id		integer;
    DECLARE @parent_account_id		integer;
    DECLARE @supplier_id			integer;
    DECLARE @account_id				integer;
	DECLARE @supplier_code			national character varying(24);
	DECLARE @currency_code			national character varying(12);
	DECLARE @supplier_name			national character varying(500);


	DECLARE supplier_cursor CURSOR FOR
	SELECT 
		supplier_type_id, supplier_id, supplier_code, account_id, currency_code, supplier_name 
	FROM INSERTED
	OPEN supplier_cursor;
	FETCH NEXT FROM supplier_cursor INTO @supplier_type_id, @supplier_id, @supplier_code, @account_id, @currency_code, @supplier_name;
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @parent_account_id			=  inventory.get_account_id_by_supplier_type_id(@supplier_type_id);

		IF(COALESCE(@supplier_name, '') = '')
		BEGIN
			RAISERROR('The supplier name cannot be left empty.', 16, 1);
		END;

		--Create a new account
		IF(@account_id IS NULL)
		BEGIN
			INSERT INTO finance.accounts(account_master_id, account_number, currency_code, account_name, parent_account_id)
			SELECT finance.get_account_master_id_by_account_id(@parent_account_id), '10110-' + CAST(@supplier_id AS varchar(50)), @currency_code, @supplier_name, @parent_account_id;
		
			SET @account_id = SCOPE_IDENTITY();
		    
			UPDATE inventory.suppliers
			SET 
				account_id		= @account_id
			WHERE inventory.suppliers.supplier_id = @supplier_id;
		END;

		FETCH NEXT FROM supplier_cursor INTO @supplier_type_id, @supplier_id, @supplier_code, @account_id, @currency_code, @supplier_name;
	END;

	CLOSE supplier_cursor;
	DEALLOCATE supplier_cursor;
END

GO