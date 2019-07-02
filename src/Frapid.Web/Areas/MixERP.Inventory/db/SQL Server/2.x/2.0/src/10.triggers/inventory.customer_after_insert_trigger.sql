IF OBJECT_ID('inventory.customer_after_insert_trigger') IS NOT NULL
DROP TRIGGER inventory.customer_after_insert_trigger;

GO

CREATE TRIGGER inventory.customer_after_insert_trigger
ON inventory.customers
AFTER INSERT
AS
BEGIN    
	DECLARE @customer_type_id		integer;
    DECLARE @parent_account_id		integer;
    DECLARE @customer_id			integer;
    DECLARE @account_id				integer;
	DECLARE @customer_code			national character varying(24);
	DECLARE @currency_code			national character varying(12);
	DECLARE @customer_name			national character varying(500);


	DECLARE customer_cursor CURSOR FOR
	SELECT 
		customer_type_id, customer_id, customer_code, account_id, currency_code, customer_name 
	FROM INSERTED
	OPEN customer_cursor;
	FETCH NEXT FROM customer_cursor INTO @customer_type_id, @customer_id, @customer_code, @account_id, @currency_code, @customer_name;
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @parent_account_id			=  inventory.get_account_id_by_customer_type_id(@customer_type_id);

		IF(COALESCE(@customer_name, '') = '')
		BEGIN
			RAISERROR('The customer name cannot be left empty.', 16, 1);
		END;

		--Create a new account
		IF(@account_id IS NULL)
		BEGIN
			INSERT INTO finance.accounts(account_master_id, account_number, currency_code, account_name, parent_account_id)
			SELECT finance.get_account_master_id_by_account_id(@parent_account_id), '15010-' + CAST(@customer_id AS varchar(50)), @currency_code, @customer_name, @parent_account_id;
		
			SET @account_id = SCOPE_IDENTITY();
		    
			UPDATE inventory.customers
			SET 
				account_id		= @account_id
			WHERE inventory.customers.customer_id = @customer_id;
		END;

		FETCH NEXT FROM customer_cursor INTO @customer_type_id, @customer_id, @customer_code, @account_id, @currency_code, @customer_name;
	END;

	CLOSE customer_cursor;
	DEALLOCATE customer_cursor;
END

GO