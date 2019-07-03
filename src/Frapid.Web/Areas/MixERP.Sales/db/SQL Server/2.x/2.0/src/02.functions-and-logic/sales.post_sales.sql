IF OBJECT_ID('sales.post_sales') IS NOT NULL
DROP PROCEDURE sales.post_sales;

GO

CREATE PROCEDURE sales.post_sales
(
    @office_id                              integer,
    @user_id                                integer,
    @login_id                               bigint,
    @counter_id                             integer,
    @value_date                             date,
    @book_date                              date,
    @cost_center_id                         integer,
    @reference_number                       national character varying(24),
    @statement_reference                    national character varying(2000),
    @tender                                 numeric(30, 6),
    @change                                 numeric(30, 6),
    @payment_term_id                        integer,
    @check_amount                           numeric(30, 6),
    @check_bank_name                        national character varying(1000),
    @check_number                           national character varying(100),
    @check_date                             date,
    @gift_card_number                       national character varying(100),
    @customer_id                            integer,
    @price_type_id                          integer,
    @shipper_id                             integer,
    @store_id                               integer,
    @coupon_code                            national character varying(100),
    @is_flat_discount                       bit,
    @discount                               numeric(30, 6),
    @details                                sales.sales_detail_type READONLY,
    @sales_quotation_id                     bigint,
    @sales_order_id                         bigint,
	@serial_number_ids						national character varying(max),
    @transaction_master_id                  bigint OUTPUT,
	@book_name								national character varying(48) = 'Sales Entry'
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @checkout_id                    bigint;
    DECLARE @grand_total                    numeric(30, 6);
    DECLARE @discount_total                 numeric(30, 6);
    DECLARE @receivable                     numeric(30, 6);
    DECLARE @default_currency_code          national character varying(12);
    DECLARE @is_periodic                    bit = inventory.is_periodic_inventory(@office_id);
    DECLARE @cost_of_goods                  numeric(30, 6);
    DECLARE @tran_counter                   integer;
    DECLARE @transaction_code               national character varying(50);
    DECLARE @tax_total                      numeric(30, 6);
    DECLARE @shipping_charge                numeric(30, 6);
    DECLARE @cash_repository_id             integer;
    DECLARE @cash_account_id                integer;
    DECLARE @is_cash                        bit = 0;
    DECLARE @is_credit                      bit = 0;
    DECLARE @gift_card_id                   integer;
    DECLARE @gift_card_balance              numeric(30, 6);
    DECLARE @coupon_id                      integer;
    DECLARE @fiscal_year_code               national character varying(12);
    DECLARE @invoice_number                 bigint;
    DECLARE @tax_account_id                 integer;
    DECLARE @receipt_transaction_master_id  bigint;

    DECLARE @total_rows                     integer = 0;
    DECLARE @counter                        integer = 0;

    DECLARE @can_post_transaction           bit;
    DECLARE @error_message                  national character varying(MAX);

	DECLARE @sales_tax_rate					numeric(30, 6);
	DECLARE @taxable_total					numeric(30, 6);
	DECLARE @nontaxable_total				numeric(30, 6);
    DECLARE @coupon_discount                numeric(30, 6); 

    DECLARE @checkout_details TABLE
    (
        id                                  integer IDENTITY PRIMARY KEY,
        checkout_id                         bigint, 
        tran_type                           national character varying(2), 
        store_id                            integer,
        item_id                             integer, 
        quantity                            numeric(30, 6),        
        unit_id                             integer,
        base_quantity                       numeric(30, 6),
        base_unit_id                        integer,                
        price                               numeric(30, 6),
        cost_of_goods_sold                  numeric(30, 6) DEFAULT(0),
        discount_rate                       numeric(30, 6),
        discount                            numeric(30, 6),
		is_taxed							bit,
		is_taxable_item						bit,
        amount								numeric(30, 6),
        shipping_charge                     numeric(30, 6),
        sales_account_id                    integer,
        sales_discount_account_id           integer,
        inventory_account_id                integer,
        cost_of_goods_sold_account_id       integer
    );

    DECLARE @item_quantities TABLE
    (
        item_id                             integer,
        base_unit_id                        integer,
        store_id                            integer,
        total_sales                         numeric(30, 6),
        in_stock                            numeric(30, 6),
        maintain_inventory                  bit
    );

    DECLARE @temp_transaction_details TABLE
    (
        transaction_master_id               bigint, 
        tran_type                           national character varying(2), 
        account_id                          integer NOT NULL, 
        statement_reference                 national character varying(2000), 
        cash_repository_id                  integer, 
        currency_code                       national character varying(12), 
        amount_in_currency                  numeric(30, 6) NOT NULL, 
        local_currency_code                 national character varying(12), 
        er                                  numeric(30, 6), 
        amount_in_local_currency			numeric(30, 6)
    ) ;

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

        SET @tax_account_id                         = finance.get_sales_tax_account_id_by_office_id(@office_id);
        SET @default_currency_code                  = core.get_currency_code_by_office_id(@office_id);
        SET @cash_account_id                        = inventory.get_cash_account_id_by_store_id(@store_id);
        SET @cash_repository_id                     = inventory.get_cash_repository_id_by_store_id(@store_id);
        SET @is_cash                                = finance.is_cash_account_id(@cash_account_id);    

        SET @coupon_id                              = sales.get_active_coupon_id_by_coupon_code(@coupon_code);
        SET @gift_card_id                           = sales.get_gift_card_id_by_gift_card_number(@gift_card_number);
        SET @gift_card_balance                      = sales.get_gift_card_balance(@gift_card_id, @value_date);


        SELECT TOP 1 @fiscal_year_code = finance.fiscal_year.fiscal_year_code
        FROM finance.fiscal_year
        WHERE @value_date BETWEEN finance.fiscal_year.starts_from AND finance.fiscal_year.ends_on;

        IF(COALESCE(@customer_id, 0) = 0)
        BEGIN
            RAISERROR('Please select a customer.', 13, 1);
        END;

        IF(COALESCE(@coupon_code, '') != '' AND COALESCE(@discount, 0) > 0)
        BEGIN
            RAISERROR('Please do not specify discount rate when you mention coupon code.', 13, 1);
        END;
        --TODO: VALIDATE COUPON CODE AND POST DISCOUNT

        IF(COALESCE(@payment_term_id, 0) > 0)
        BEGIN
            SET @is_credit                          = 1;
        END;

        IF(@is_credit = 0 AND @is_cash = 0)
        BEGIN
            RAISERROR('Cannot post sales. Invalid cash account mapping on store.', 13, 1);
        END;

       
        IF(@is_cash = 0)
        BEGIN
            SET @cash_repository_id                 = NULL;
        END;

		SELECT @sales_tax_rate = finance.tax_setups.sales_tax_rate
		FROM finance.tax_setups
		WHERE finance.tax_setups.deleted = 0
		AND finance.tax_setups.office_id = @office_id;

        INSERT INTO @checkout_details(store_id, item_id, quantity, unit_id, price, discount_rate, discount, is_taxed, shipping_charge)
        SELECT store_id, item_id, quantity, unit_id, price, discount_rate, discount, is_taxed, shipping_charge
        FROM @details;


        UPDATE @checkout_details 
        SET
            tran_type                       = 'Cr',
            base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
            base_unit_id                    = inventory.get_root_unit_id(unit_id);

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
            sales_account_id                = inventory.get_sales_account_id(item_id),
            sales_discount_account_id       = inventory.get_sales_discount_account_id(item_id),
            inventory_account_id            = inventory.get_inventory_account_id(item_id),
            cost_of_goods_sold_account_id   = inventory.get_cost_of_goods_sold_account_id(item_id);

		UPDATE @checkout_details 
		SET 
			is_taxable_item = inventory.items.is_taxable_item
		FROM @checkout_details AS checkout_details
		INNER JOIN inventory.items
		ON inventory.items.item_id = checkout_details.item_id;

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

        INSERT INTO @item_quantities(item_id, base_unit_id, store_id, total_sales)
        SELECT item_id, base_unit_id, store_id, SUM(base_quantity)
        FROM @checkout_details
        GROUP BY item_id, base_unit_id, store_id;

        UPDATE @item_quantities
        SET maintain_inventory = inventory.items.maintain_inventory
        FROM @item_quantities AS item_quantities 
        INNER JOIN inventory.items
        ON item_quantities.item_id = inventory.items.item_id;
        
        UPDATE @item_quantities
        SET in_stock = inventory.count_item_in_stock(item_id, base_unit_id, store_id)
        WHERE maintain_inventory = 1;


        IF EXISTS
        (
            SELECT TOP 1 0 FROM @item_quantities
            WHERE total_sales > in_stock
            AND maintain_inventory = 1     
        )
        BEGIN
            RAISERROR('Insufficient item quantity', 13, 1);
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
			@taxable_total		= COALESCE(SUM(CASE WHEN is_taxable_item = 1 THEN 1 ELSE 0 END * COALESCE(amount, 0)), 0),
			@nontaxable_total	= COALESCE(SUM(CASE WHEN is_taxable_item = 0 THEN 1 ELSE 0 END * COALESCE(amount, 0)), 0)
		FROM @checkout_details;


        SELECT @discount_total  = ROUND(SUM(COALESCE(discount, 0)), 2) FROM @checkout_details;
        SELECT @shipping_charge = SUM(COALESCE(shipping_charge, 0)) FROM @checkout_details;
            

        SET @coupon_discount                = ROUND(@discount, 2);

        IF(@is_flat_discount = 0 AND COALESCE(@discount, 0) > 0)
        BEGIN
            SET @coupon_discount            = ROUND(COALESCE(@taxable_total, 0) * (@discount/100), 2);
        END;

		IF(@coupon_discount > @taxable_total)
		BEGIN
			RAISERROR('The coupon discount cannot be greater than total taxable amount.', 16, 1);
		END;


        SELECT @tax_total       = ROUND((COALESCE(@taxable_total, 0) - COALESCE(@coupon_discount, 0)) * (@sales_tax_rate / 100), 2);
        SELECT @grand_total     = COALESCE(@taxable_total, 0) + COALESCE(@nontaxable_total, 0) + COALESCE(@tax_total, 0) - COALESCE(@coupon_discount, 0);

		SET @receivable         = @grand_total;


        IF(@is_flat_discount = 1 AND @discount > @receivable)
        BEGIN
			SET @error_message = FORMATMESSAGE('The discount amount %s cannot be greater than total amount %s.', CAST(@discount AS varchar(30)), CAST(@receivable AS varchar(30)));
            RAISERROR(@error_message, 13, 1);
        END
        ELSE IF(@is_flat_discount = 0 AND @discount > 100)
        BEGIN
            RAISERROR('The discount rate cannot be greater than 100.', 13, 1);
        END;

        IF(@tender > 0)
        BEGIN
            IF(@tender < @receivable)
            BEGIN
                SET @error_message = FORMATMESSAGE('The tender amount must be greater than or equal to %s.', CAST(@receivable AS varchar(30)));
                RAISERROR(@error_message, 13, 1);
            END;
        END
        ELSE IF(@check_amount > 0)
        BEGIN
            IF(@check_amount < @receivable )
            BEGIN
                SET @error_message = FORMATMESSAGE('The check amount must be greater than or equal to %s.', CAST(@receivable AS varchar(30)));
                RAISERROR(@error_message, 13, 1);
            END;
        END
        ELSE IF(COALESCE(@gift_card_number, '') != '')
        BEGIN
            IF(@gift_card_balance < @receivable )
            BEGIN
                SET @error_message = FORMATMESSAGE('The gift card must have a balance of at least %s.', CAST(@receivable AS varchar(30)));
                RAISERROR(@error_message, 13, 1);
            END;
        END;
        


        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Cr', sales_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0)), 1, @default_currency_code, SUM(COALESCE(price, 0) * COALESCE(quantity, 0))
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
                SELECT 'Dr', cost_of_goods_sold_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
                FROM @checkout_details
                GROUP BY cost_of_goods_sold_account_id;

                INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
                SELECT 'Cr', inventory_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0)), 1, @default_currency_code, SUM(COALESCE(cost_of_goods_sold, 0))
                FROM @checkout_details
                GROUP BY inventory_account_id;
            END;
        END;

        IF(COALESCE(@tax_total, 0) > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Cr', @tax_account_id, @statement_reference, @default_currency_code, @tax_total, 1, @default_currency_code, @tax_total;
        END;

        IF(COALESCE(@shipping_charge, 0) > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Cr', inventory.get_account_id_by_shipper_id(@shipper_id), @statement_reference, @default_currency_code, @shipping_charge, 1, @default_currency_code, @shipping_charge;                
        END;


        IF(COALESCE(@discount_total, 0) > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', sales_discount_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(discount, 0)), 1, @default_currency_code, SUM(COALESCE(discount, 0))
            FROM @checkout_details
            GROUP BY sales_discount_account_id
            HAVING SUM(COALESCE(discount, 0)) > 0;
        END;

        IF(COALESCE(@coupon_discount, 0) > 0)
        BEGIN
			DECLARE @sales_discount_account_id integer;

			SELECT @sales_discount_account_id = inventory.stores.sales_discount_account_id
			FROM inventory.stores
			WHERE inventory.stores.store_id = @store_id;

            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', @sales_discount_account_id, @statement_reference, @default_currency_code, @coupon_discount, 1, @default_currency_code, @coupon_discount;
        END;


        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', inventory.get_account_id_by_customer_id(@customer_id), @statement_reference, @default_currency_code, @receivable, 1, @default_currency_code, @receivable;
        
		IF
		(
			SELECT SUM(CASE WHEN tran_type = 'Cr' THEN 1 ELSE -1 END * amount_in_local_currency)
			FROM @temp_transaction_details
		) != 0
		BEGIN
			SELECT finance.get_account_name_by_account_id(account_id), * FROM @temp_transaction_details ORDER BY tran_type;
			RAISERROR('Could not balance the Journal Entry. Nothing was saved.', 16, 1);		
		END;
		

        SET @tran_counter           = finance.get_new_transaction_counter(@value_date);
        SET @transaction_code       = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id);

        
        INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference) 
        SELECT @tran_counter, @transaction_code, @book_name, @value_date, @book_date, @user_id, @login_id, @office_id, @cost_center_id, @reference_number, @statement_reference;
        SET @transaction_master_id  = SCOPE_IDENTITY();
        UPDATE @temp_transaction_details        SET transaction_master_id   = @transaction_master_id;


        INSERT INTO finance.transaction_details(value_date, book_date, office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency)
        SELECT @value_date, @book_date, @office_id, transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency
        FROM @temp_transaction_details
        ORDER BY tran_type DESC;

        INSERT INTO inventory.checkouts(transaction_book, value_date, book_date, transaction_master_id, shipper_id, posted_by, office_id, discount, taxable_total, tax_rate, tax, nontaxable_total)
        SELECT @book_name, @value_date, @book_date, @transaction_master_id, @shipper_id, @user_id, @office_id, @coupon_discount, @taxable_total, @sales_tax_rate, @tax_total, @nontaxable_total;

        SET @checkout_id              = SCOPE_IDENTITY();    
        
        UPDATE @checkout_details
        SET checkout_id             = @checkout_id;

        INSERT INTO inventory.checkout_details(value_date, book_date, checkout_id, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, cost_of_goods_sold, discount_rate, discount, shipping_charge, is_taxed)
        SELECT @value_date, @book_date, checkout_id, tran_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, COALESCE(cost_of_goods_sold, 0), discount_rate, discount, shipping_charge, is_taxable_item
        FROM @checkout_details;


        SELECT @invoice_number = COALESCE(MAX(invoice_number), 0) + 1
        FROM sales.sales
        WHERE sales.sales.fiscal_year_code = @fiscal_year_code;
        

        IF(@is_credit = 0 AND @book_name = 'Sales Entry')
        BEGIN
            EXECUTE sales.post_receipt
                @user_id, 
                @office_id, 
                @login_id,
                @customer_id,
                @default_currency_code, 
                1.0, 
                1.0,
                @reference_number, 
                @statement_reference, 
                @cost_center_id,
                @cash_account_id,
                @cash_repository_id,
                @value_date,
                @book_date,
                @receivable,
                @tender,
                @change,
                @check_amount,
                @check_bank_name,
                @check_number,
                @check_date,
                @gift_card_number,
                @store_id,
                @transaction_master_id,--CASCADING TRAN ID
				@receipt_transaction_master_id OUTPUT;

			EXECUTE finance.auto_verify @receipt_transaction_master_id, @office_id;

			IF @serial_number_ids IS NOT NULL
			BEGIN
				DECLARE @sql nvarchar(max) = 
				'UPDATE inventory.serial_numbers SET sales_transaction_id = '+ CAST(@transaction_master_id AS nvarchar(50))+'
				WHERE serial_number_id IN (' + @serial_number_ids + ')'

				EXEC sp_executesql @sql;
			END
        END
        ELSE
        BEGIN

            EXECUTE sales.settle_customer_due @customer_id, @office_id;
        END;

		IF(@book_name = 'Sales Entry')
		BEGIN
			INSERT INTO sales.sales(fiscal_year_code, invoice_number, price_type_id, counter_id, total_amount, cash_repository_id, sales_order_id, sales_quotation_id, transaction_master_id, checkout_id, customer_id, salesperson_id, coupon_id, is_flat_discount, discount, total_discount_amount, is_credit, payment_term_id, tender, change, check_number, check_date, check_bank_name, check_amount, gift_card_id, receipt_transaction_master_id)
			SELECT @fiscal_year_code, @invoice_number, @price_type_id, @counter_id, @receivable, @cash_repository_id, @sales_order_id, @sales_quotation_id, @transaction_master_id, @checkout_id, @customer_id, @user_id, @coupon_id, @is_flat_discount, @discount, @discount_total, @is_credit, @payment_term_id, @tender, @change, @check_number, @check_date, @check_bank_name, @check_amount, @gift_card_id, @receipt_transaction_master_id;
		END;
		        
		EXECUTE finance.auto_verify @transaction_master_id, @office_id;

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


-- DECLARE @office_id								integer 							= (SELECT TOP 1 office_id FROM core.offices);
-- DECLARE @user_id                                integer 							= (SELECT TOP 1 user_id FROM account.users);
-- DECLARE @login_id                               bigint  							= (SELECT TOP 1 login_id FROM account.logins WHERE user_id = @user_id);
-- DECLARE @counter_id                             integer								= (SELECT TOP 1 counter_id FROM inventory.counters);
-- DECLARE @value_date                             date								= finance.get_value_date(@office_id);
-- DECLARE @book_date                              date								= finance.get_value_date(@office_id);
-- DECLARE @cost_center_id                         integer								= (SELECT TOP 1 cost_center_id FROM finance.cost_centers);
-- DECLARE @reference_number                       national character varying(24)		= 'N/A';
-- DECLARE @statement_reference                    national character varying(2000)	= 'Test';
-- DECLARE @tender                                 numeric(30, 6)						= 20000;
-- DECLARE @change                                 numeric(30, 6)						= 10;
-- DECLARE @payment_term_id                        integer								= NULL;
-- DECLARE @check_amount                           numeric(30, 6)						= NULL;
-- DECLARE @check_bank_name                        national character varying(1000)	= NULL;
-- DECLARE @check_number                           national character varying(100)		= NULL;
-- DECLARE @check_date                             date								= NULL;
-- DECLARE @gift_card_number                       national character varying(100)		= NULL;
-- DECLARE @customer_id                            integer								= (SELECT TOP 1 customer_id FROM inventory.customers);
-- DECLARE @price_type_id                          integer								= (SELECT TOP 1 price_type_id FROM sales.price_types);
-- DECLARE @shipper_id                             integer								= (SELECT TOP 1 shipper_id FROM inventory.shippers);
-- DECLARE @store_id                               integer								= (SELECT TOP 1 store_id FROM inventory.stores WHERE store_name='Cold Room RM');
-- DECLARE @coupon_code                            national character varying(100)		= NULL;
-- DECLARE @is_flat_discount                       bit									= 0;
-- DECLARE @discount                               numeric(30, 6)						= 20;
-- DECLARE @details                                sales.sales_detail_type;
-- DECLARE @sales_quotation_id                     bigint								= NULL;
-- DECLARE @sales_order_id                         bigint								= NULL;
-- DECLARE @transaction_master_id                  bigint								= NULL;

-- INSERT INTO @details(store_id, transaction_type, item_id, quantity, unit_id, price, shipping_charge, discount_rate, discount)  
-- --SELECT @store_id, 'Cr', item_id, 1, unit_id, selling_price, 0, selling_price * 0.13, 0
-- --FROM inventory.items
-- --WHERE inventory.items.item_code IN('SHS0003', 'SHS0004');
-- SELECT @store_id, 'Cr', 1, 1, 6, 2320, 100, 0, 0;


-- EXECUTE sales.post_sales
    -- @office_id,
    -- @user_id,
    -- @login_id,
    -- @counter_id,
    -- @value_date,
    -- @book_date,
    -- @cost_center_id,
    -- @reference_number,
    -- @statement_reference,
    -- @tender,
    -- @change, 
    -- @payment_term_id,
	-- @check_amount,
    -- @check_bank_name,
    -- @check_number,
    -- @check_date,
	-- @gift_card_number,
    -- @customer_id,    
    -- @price_type_id,
    -- @shipper_id,
    -- @store_id,
    -- @coupon_code,
    -- @is_flat_discount,
    -- @discount,
    -- @details,
    -- @sales_quotation_id,
    -- @sales_order_id,  
    -- @transaction_master_id OUTPUT;

