IF OBJECT_ID('sales.post_return_without_validation') IS NOT NULL
DROP PROCEDURE sales.post_return_without_validation;

GO

CREATE PROCEDURE sales.post_return_without_validation
(
    @office_id                      integer,
    @user_id                        integer,
    @login_id                       bigint,
    @value_date                     date,
    @book_date                      date,
    @store_id                       integer,
    @counter_id                     integer,
    @customer_id                    integer,
    @price_type_id                  integer,
    @reference_number               national character varying(24),
    @statement_reference            national character varying(2000),
    @details                        sales.sales_detail_type READONLY,
	@shipper_id						integer,
	@discount						numeric(30, 6),
    @tran_master_id                 bigint OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @book_name						national character varying(50) = 'Sales Return';
    DECLARE @cost_center_id					bigint;
    DECLARE @tran_counter					integer;
    DECLARE @tran_code						national character varying(50);
    DECLARE @checkout_id					bigint;
    DECLARE @grand_total					numeric(30, 6);
    DECLARE @discount_total					numeric(30, 6);
    DECLARE @default_currency_code			national character varying(12);
    DECLARE @tax_total						numeric(30, 6);
    DECLARE @tax_account_id					integer;
    DECLARE @can_post_transaction			bit;
    DECLARE @error_message					national character varying(MAX);
	DECLARE @sales_tax_rate					numeric(30, 6);
	DECLARE @taxable_total					numeric(30, 6);
	DECLARE @nontaxable_total				numeric(30, 6);
    DECLARE @invoice_discount				numeric(30, 6);
    DECLARE @shipping_charge                numeric(30, 6);
    DECLARE @payable						numeric(30, 6);
    DECLARE @transaction_code               national character varying(50);
    DECLARE @is_periodic                    bit = inventory.is_periodic_inventory(@office_id);
	DECLARE @transaction_master_id			bigint;
    DECLARE @cost_of_goods                  numeric(30, 6);

    DECLARE @checkout_details TABLE
    (
        id                                  integer IDENTITY PRIMARY KEY,
        checkout_id                         bigint, 
        store_id                            integer,
        transaction_type                    national character varying(2),
        item_id                             integer, 
        quantity                            numeric(30, 6),
        unit_id                             integer,
        base_quantity                       numeric(30, 6),
        base_unit_id                        integer,
        price                               numeric(30, 6) NOT NULL DEFAULT(0),
        cost_of_goods_sold                  numeric(30, 6) NOT NULL DEFAULT(0),
        discount_rate                       numeric(30, 6),
        discount                            numeric(30, 6) NOT NULL DEFAULT(0),
		is_taxable_item						bit,
		is_taxed							bit,
        amount								numeric(30, 6),
        shipping_charge                     numeric(30, 6) NOT NULL DEFAULT(0),
        sales_account_id					integer, 
        sales_discount_account_id			integer, 
        inventory_account_id                integer,
        cost_of_goods_sold_account_id       integer
    );

    DECLARE @temp_transaction_details TABLE
    (
        transaction_master_id               bigint, 
        tran_type                           national character varying(4), 
        account_id                          integer, 
        statement_reference                 national character varying(2000), 
        currency_code                       national character varying(12), 
        amount_in_currency                  numeric(30, 6), 
        local_currency_code                 national character varying(12), 
        er                                  numeric(30, 6), 
        amount_in_local_currency            numeric(30, 6)
    );

    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
    	    
        SELECT
            @can_post_transaction   = can_post_transaction,
            @error_message          = error_message
        FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book_name, @value_date);

        IF(@can_post_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 13, 1);
            RETURN;
        END;

        SET @tax_account_id                 = finance.get_sales_tax_account_id_by_office_id(@office_id);

        IF(COALESCE(@customer_id, 0) = 0)
        BEGIN
            RAISERROR('Invalid customer', 13, 1);
        END;
        


		SELECT @sales_tax_rate = finance.tax_setups.sales_tax_rate
		FROM finance.tax_setups
		WHERE finance.tax_setups.deleted = 0
		AND finance.tax_setups.office_id = @office_id;

        INSERT INTO @checkout_details(store_id, transaction_type, item_id, quantity, unit_id, price, discount_rate, discount, shipping_charge, is_taxed)
        SELECT store_id, 'Dr', item_id, quantity, unit_id, price, discount_rate, discount, shipping_charge, COALESCE(is_taxed, 1)
        FROM @details;

        UPDATE @checkout_details 
        SET
            base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
            base_unit_id                    = inventory.get_root_unit_id(unit_id),
            sales_account_id				= inventory.get_sales_account_id(item_id),
            sales_discount_account_id		= inventory.get_sales_discount_account_id(item_id),
            inventory_account_id            = inventory.get_inventory_account_id(item_id),
            cost_of_goods_sold_account_id   = inventory.get_cost_of_goods_sold_account_id(item_id);
        
		UPDATE @checkout_details
		SET
            discount                        = COALESCE(ROUND(((price * quantity) + shipping_charge) * (discount_rate / 100), 2), 0)
		WHERE COALESCE(discount, 0) = 0;

		UPDATE @checkout_details
		SET
            discount_rate                   = COALESCE(ROUND(100 * discount / ((price * quantity) + shipping_charge), 2), 0)
		WHERE COALESCE(discount_rate, 0) = 0;


		UPDATE @checkout_details 
		SET 
			is_taxable_item = inventory.items.is_taxable_item
		FROM @checkout_details AS checkout_details
		INNER JOIN inventory.items
		ON inventory.items.item_id = checkout_details.item_id;

		UPDATE @checkout_details
		SET is_taxed = 0
		WHERE is_taxable_item = 0;

		UPDATE @checkout_details
		SET amount = (COALESCE(price, 0) * COALESCE(quantity, 0)) - COALESCE(discount, 0) + COALESCE(shipping_charge, 0);

		IF EXISTS
		(
			SELECT 1
			FROM @checkout_details
			WHERE amount < 0
		)
		BEGIN
			RAISERROR('A line amount cannot be less than zero.', 16, 1);
		END;

        IF EXISTS
        (
            SELECT TOP 1 0 FROM @checkout_details AS details
            WHERE inventory.is_valid_unit_id(details.unit_id, details.item_id) = 0
        )
        BEGIN
            RAISERROR('Item/unit mismatch.', 13, 1);
        END;

		SELECT 
			@taxable_total		= COALESCE(SUM(CASE WHEN is_taxed = 1 THEN 1 ELSE 0 END * COALESCE(amount, 0)), 0),
			@nontaxable_total	= COALESCE(SUM(CASE WHEN is_taxed = 0 THEN 1 ELSE 0 END * COALESCE(amount, 0)), 0)
		FROM @checkout_details;

		IF(@invoice_discount > @taxable_total)
		BEGIN
			RAISERROR('The invoice discount cannot be greater than total taxable amount.', 16, 1);
		END;

        SELECT @discount_total				= SUM(COALESCE(discount, 0)) FROM @checkout_details;

        SELECT @shipping_charge				= SUM(COALESCE(shipping_charge, 0)) FROM @checkout_details;
        SELECT @tax_total					= ROUND((COALESCE(@taxable_total, 0) - COALESCE(@invoice_discount, 0)) * (@sales_tax_rate / 100), 2);
        SELECT @grand_total					= COALESCE(@taxable_total, 0) + COALESCE(@nontaxable_total, 0) + COALESCE(@tax_total, 0) - COALESCE(@discount_total, 0)  - COALESCE(@invoice_discount, 0);
        SET @payable						= @grand_total;

        SET @default_currency_code          = core.get_currency_code_by_office_id(@office_id);
        SET @tran_counter                   = finance.get_new_transaction_counter(@value_date);
        SET @transaction_code               = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id);









        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', sales_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0)), 1, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0))
        FROM @checkout_details
        GROUP BY sales_account_id;

        IF(@is_periodic = 0)
        BEGIN
            --Perpetutal Inventory Accounting System
            UPDATE @checkout_details SET cost_of_goods_sold = inventory.get_cost_of_goods_sold(item_id, unit_id, store_id, quantity);

            SELECT @cost_of_goods = SUM(cost_of_goods_sold)
            FROM @checkout_details;


            IF(@cost_of_goods > 0)
            BEGIN
                INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
                SELECT 'Cr', cost_of_goods_sold_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
                FROM @checkout_details
                GROUP BY cost_of_goods_sold_account_id;

                INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
                SELECT 'Dr', inventory_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
                FROM @checkout_details
                GROUP BY inventory_account_id;
            END;
        END;

        IF(COALESCE(@tax_total, 0) > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', @tax_account_id, @statement_reference, @default_currency_code, @tax_total, 1, @default_currency_code, @tax_total;
        END;

        IF(COALESCE(@shipping_charge, 0) > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', inventory.get_account_id_by_shipper_id(@shipper_id), @statement_reference, @default_currency_code, @shipping_charge, 1, @default_currency_code, @shipping_charge;                
        END;


        IF(COALESCE(@discount_total, 0) > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Cr', sales_discount_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(discount, 0)), 1, @default_currency_code, SUM(COALESCE(discount, 0))
            FROM @checkout_details
            GROUP BY sales_discount_account_id
            HAVING SUM(COALESCE(discount, 0)) > 0;
        END;


        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Cr', inventory.get_account_id_by_customer_id(@customer_id), @statement_reference, @default_currency_code, @payable, 1, @default_currency_code, @payable;
        
		IF
		(
			SELECT SUM(CASE WHEN tran_type = 'Cr' THEN 1 ELSE -1 END * amount_in_local_currency)
			FROM @temp_transaction_details
		) != 0
		BEGIN
			SELECT finance.get_account_name_by_account_id(account_id), * FROM @temp_transaction_details ORDER BY tran_type;
			RAISERROR('Could not balance the Journal Entry. Nothing was saved.', 16, 1);		
		END;
		




















        INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference) 
        SELECT @tran_counter, @transaction_code, @book_name, @value_date, @book_date, @user_id, @login_id, @office_id, @cost_center_id, @reference_number, @statement_reference;
        SET @transaction_master_id = SCOPE_IDENTITY();
        
        INSERT INTO finance.transaction_details(value_date, book_date, office_id, transaction_master_id, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency)
        SELECT @value_date, @book_date, @office_id, @transaction_master_id, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency
        FROM @temp_transaction_details
        ORDER BY tran_type DESC;


        INSERT INTO inventory.checkouts(value_date, book_date, transaction_master_id, transaction_book, posted_by, shipper_id, office_id, discount, taxable_total, tax_rate, tax, nontaxable_total)
        SELECT @value_date, @book_date, @transaction_master_id, @book_name, @user_id, @shipper_id, @office_id, @invoice_discount, @taxable_total, @sales_tax_rate, @tax_total, @nontaxable_total;
        SET @checkout_id                = SCOPE_IDENTITY();


        INSERT INTO inventory.checkout_details(checkout_id, value_date, book_date, store_id, transaction_type, item_id, price, discount_rate, discount, cost_of_goods_sold, shipping_charge, unit_id, quantity, base_unit_id, base_quantity)
        SELECT @checkout_id, @value_date, @book_date, store_id, transaction_type, item_id, price, discount_rate, discount, cost_of_goods_sold, shipping_charge, unit_id, quantity, base_unit_id, base_quantity
        FROM @checkout_details;
        

        EXECUTE finance.auto_verify @transaction_master_id, @office_id;


		INSERT INTO sales.returns(sales_id, checkout_id, transaction_master_id, return_transaction_master_id, counter_id, customer_id, price_type_id)
		SELECT NULL, @checkout_id, NULL, @transaction_master_id, @counter_id, @customer_id, @price_type_id;

		SET @tran_master_id = @transaction_master_id;

        IF(@tran_count = 0)
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE() <> 0 AND @tran_count = 0) 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ErrorMessage national character varying(4000)  = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int                              = ERROR_SEVERITY();
        DECLARE @ErrorState int                                 = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

GO




--DECLARE @transaction_master_id          bigint = 369;
--DECLARE @office_id                      integer = (SELECT TOP 1 office_id FROM core.offices);
--DECLARE @user_id                        integer = (SELECT TOP 1 user_id FROM account.users);
--DECLARE @login_id                       bigint = (SELECT TOP 1 login_id FROM account.logins WHERE user_id = @user_id);
--DECLARE @value_date                     date = finance.get_value_date(@office_id);
--DECLARE @book_date                      date = finance.get_value_date(@office_id);
--DECLARE @store_id                       integer = (SELECT TOP 1 store_id FROM inventory.stores);
--DECLARE @counter_id                     integer = (SELECT TOP 1 counter_id FROM inventory.counters);
--DECLARE @customer_id                    integer = (SELECT TOP 1 customer_id FROM inventory.customers);
--DECLARE @price_type_id                  integer = (SELECT TOP 1 price_type_id FROM sales.price_types);
--DECLARE @reference_number               national character varying(24) = 'N/A';
--DECLARE @statement_reference            national character varying(2000) = 'Test';
--DECLARE @details                        sales.sales_detail_type;
--DECLARE @tran_master_id                 bigint;

--INSERT INTO @details(store_id, transaction_type, item_id, quantity, unit_id, price, discount, shipping_charge, is_taxed)
--SELECT @store_id, 'Cr', 1, 1, 1, 2320, 62.84, 0, 1;


--EXECUTE sales.post_return_without_validation
--    @office_id                      ,
--    @user_id                        ,
--    @login_id                       ,
--    @value_date                     ,
--    @book_date                      ,
--    @store_id                       ,
--    @counter_id                     ,
--    @customer_id                    ,
--    @price_type_id                  ,
--    @reference_number               ,
--    @statement_reference            ,
--    @details                        ,
--	1,
--	0,
--    @tran_master_id                 OUTPUT;

