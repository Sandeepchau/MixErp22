IF OBJECT_ID('purchase.post_return_without_validation') IS NOT NULL
DROP PROCEDURE purchase.post_return_without_validation;

GO

CREATE PROCEDURE purchase.post_return_without_validation
(
    @office_id                              integer,
    @user_id                                integer,
    @login_id                               bigint,
    @value_date                             date,
    @book_date                              date,
    @store_id								integer,
    @cost_center_id                         integer,
    @supplier_id                            integer,
    @price_type_id                          integer,
    @shipper_id                             integer,
    @reference_number                       national character varying(24),
    @statement_reference                    national character varying(2000),
    @details                                purchase.purchase_detail_type READONLY,
	@invoice_discount						numeric(30, 6),
    @tran_master_id                         bigint OUTPUT
)
AS
BEGIN    
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @checkout_id                    bigint;
    DECLARE @checkout_detail_id             bigint;
    DECLARE @shipping_address_id            integer;
    DECLARE @grand_total                    numeric(30, 6);
    DECLARE @discount_total                 numeric(30, 6);
    DECLARE @payable                        numeric(30, 6);
    DECLARE @default_currency_code          national character varying(12);
    DECLARE @is_periodic                    bit = inventory.is_periodic_inventory(@office_id);
    DECLARE @tran_counter                   integer;
    DECLARE @transaction_code               national character varying(50);
    DECLARE @tax_total                      numeric(30, 6);
    DECLARE @tax_account_id                 integer;
    DECLARE @shipping_charge                numeric(30, 6);
	DECLARE @sales_tax_rate					numeric(30, 6);
    DECLARE @book_name						national character varying(50) = 'Purchase Return';
    DECLARE @can_post_transaction           bit;
    DECLARE @error_message                  national character varying(MAX);
	DECLARE @taxable_total					numeric(30, 6);
	DECLARE @nontaxable_total				numeric(30, 6);

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
        purchase_account_id                 integer, 
        purchase_discount_account_id        integer, 
        inventory_account_id                integer
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
            @can_post_transaction           = can_post_transaction,
            @error_message                  = error_message
        FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book_name, @value_date);

        IF(@can_post_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 13, 1);
            RETURN;
        END;

        SET @tax_account_id                 = finance.get_sales_tax_account_id_by_office_id(@office_id);

        IF(COALESCE(@supplier_id, 0) = 0)
        BEGIN
            RAISERROR('Invalid supplier', 13, 1);
        END;
        


		SELECT @sales_tax_rate = finance.tax_setups.sales_tax_rate
		FROM finance.tax_setups
		WHERE finance.tax_setups.deleted = 0
		AND finance.tax_setups.office_id = @office_id;

        INSERT INTO @checkout_details(store_id, transaction_type, item_id, quantity, unit_id, price, discount_rate, discount, shipping_charge, is_taxed)
        SELECT store_id, 'Cr', item_id, quantity, unit_id, price, discount_rate, discount, shipping_charge, COALESCE(is_taxed, 1)
        FROM @details;

        UPDATE @checkout_details 
        SET
            base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
            base_unit_id                    = inventory.get_root_unit_id(unit_id),
            purchase_account_id             = inventory.get_purchase_account_id(item_id),
            purchase_discount_account_id    = inventory.get_purchase_discount_account_id(item_id),
            inventory_account_id            = inventory.get_inventory_account_id(item_id);
        
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

        IF(@is_periodic = 1)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 
				'Cr', purchase_account_id, @statement_reference, @default_currency_code, 
				SUM((COALESCE(price, 0) * COALESCE(quantity, 0)) - COALESCE(discount, 0) + COALESCE(shipping_charge, 0)), 
				1, @default_currency_code, 
				SUM((COALESCE(price, 0) * COALESCE(quantity, 0)) - COALESCE(discount, 0) + COALESCE(shipping_charge, 0))
            FROM @checkout_details
            GROUP BY purchase_account_id;
        END
        ELSE
        BEGIN
            --Perpetutal Inventory Accounting System
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 
				'Cr', inventory_account_id, @statement_reference, @default_currency_code, 
				SUM((COALESCE(price, 0) * COALESCE(quantity, 0)) - COALESCE(discount, 0) + COALESCE(shipping_charge, 0)), 
				1, @default_currency_code, 
				SUM((COALESCE(price, 0) * COALESCE(quantity, 0)) - COALESCE(discount, 0) + COALESCE(shipping_charge, 0))
            FROM @checkout_details
            GROUP BY inventory_account_id;
        END;


        IF(@discount_total > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', purchase_discount_account_id, @statement_reference, @default_currency_code, SUM(COALESCE(discount, 0)), 1, @default_currency_code, SUM(COALESCE(discount, 0))
            FROM @checkout_details
            GROUP BY purchase_discount_account_id;
        END;

        IF(@invoice_discount > 0)
        BEGIN
			DECLARE @purchase_discount_account_id integer;

			SELECT @purchase_discount_account_id = inventory.stores.purchase_discount_account_id
			FROM inventory.stores
			WHERE inventory.stores.store_id = @store_id;

            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Dr', @purchase_discount_account_id, @statement_reference, @default_currency_code, @invoice_discount, 1, @default_currency_code, @invoice_discount;
        END;


        IF(COALESCE(@tax_total, 0) > 0)
        BEGIN
            INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
            SELECT 'Cr', @tax_account_id, @statement_reference, @default_currency_code, @tax_total, 1, @default_currency_code, @tax_total;
        END;    


        INSERT INTO @temp_transaction_details(tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
        SELECT 'Dr', inventory.get_account_id_by_supplier_id(@supplier_id), @statement_reference, @default_currency_code, @payable, 1, @default_currency_code, @payable;
        

		IF
		(
			SELECT SUM(CASE WHEN tran_type = 'Cr' THEN 1 ELSE -1 END * amount_in_local_currency)
			FROM @temp_transaction_details
		) != 0
		BEGIN
			--SELECT finance.get_account_name_by_account_id(account_id), * FROM @temp_transaction_details ORDER BY tran_type;
			RAISERROR('Could not balance the Journal Entry. Nothing was saved.', 16, 1);		
		END;

        INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference) 
        SELECT @tran_counter, @transaction_code, @book_name, @value_date, @book_date, @user_id, @login_id, @office_id, @cost_center_id, @reference_number, @statement_reference;
        SET @tran_master_id = SCOPE_IDENTITY();

        UPDATE @temp_transaction_details SET transaction_master_id = @tran_master_id;        
        UPDATE @checkout_details SET checkout_id = @checkout_id;
        
        INSERT INTO finance.transaction_details(value_date, book_date, office_id, transaction_master_id, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency)
        SELECT @value_date, @book_date, @office_id, @tran_master_id, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency
        FROM @temp_transaction_details
        ORDER BY tran_type DESC;


        INSERT INTO inventory.checkouts(value_date, book_date, transaction_master_id, transaction_book, posted_by, shipper_id, office_id, discount, taxable_total, tax_rate, tax, nontaxable_total)
        SELECT @value_date, @book_date, @tran_master_id, @book_name, @user_id, @shipper_id, @office_id, @invoice_discount, @taxable_total, @sales_tax_rate, @tax_total, @nontaxable_total;
        SET @checkout_id                = SCOPE_IDENTITY();

        INSERT INTO purchase.purchases(checkout_id, supplier_id, price_type_id)
        SELECT @checkout_id, @supplier_id, @price_type_id;

        INSERT INTO inventory.checkout_details(checkout_id, value_date, book_date, store_id, transaction_type, item_id, price, discount_rate, discount, cost_of_goods_sold, shipping_charge, unit_id, quantity, base_unit_id, base_quantity, is_taxed)
        SELECT @checkout_id, @value_date, @book_date, store_id, transaction_type, item_id, price, discount_rate, discount, cost_of_goods_sold, shipping_charge, unit_id, quantity, base_unit_id, base_quantity, is_taxed
        FROM @checkout_details;
        

		ALTER TABLE purchase.purchase_returns
		ALTER COLUMN purchase_id bigint NULL;

		INSERT INTO purchase.purchase_returns(purchase_id, checkout_id, supplier_id)
		SELECT NULL, @checkout_id, @supplier_id;

        EXECUTE finance.auto_verify @tran_master_id, @office_id;

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


