IF OBJECT_ID('sales.post_return') IS NOT NULL
DROP PROCEDURE sales.post_return;

GO

CREATE PROCEDURE sales.post_return
(
    @transaction_master_id          bigint,
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

	DECLARE @reversal_tran_id		bigint;
	DECLARE @new_tran_id			bigint;
    DECLARE @book_name              national character varying(50) = 'Sales Return';
    DECLARE @cost_center_id         bigint;
    DECLARE @tran_counter           integer;
    DECLARE @tran_code              national character varying(50);
    DECLARE @checkout_id            bigint;
    DECLARE @grand_total            numeric(30, 6);
    DECLARE @discount_total         numeric(30, 6);
    DECLARE @is_credit              bit;
    DECLARE @default_currency_code  national character varying(12);
    DECLARE @cost_of_goods_sold     numeric(30, 6);
    DECLARE @ck_id                  bigint;
    DECLARE @sales_id               bigint;
    DECLARE @tax_total              numeric(30, 6);
    DECLARE @tax_account_id         integer;
	DECLARE @fiscal_year_code		national character varying(12);
    DECLARE @can_post_transaction   bit;
    DECLARE @error_message          national character varying(MAX);
	DECLARE @original_checkout_id	bigint;
	DECLARE @original_customer_id	integer;
	DECLARE @difference				sales.sales_detail_type;
	DECLARE @validate				bit;

	SELECT @validate = validate_returns 
	FROM inventory.inventory_setup
	WHERE office_id = @office_id;

	IF(COALESCE(@transaction_master_id, 0) = 0 AND @validate = 0)
	BEGIN
		EXECUTE sales.post_return_without_validation
			@office_id                      ,
			@user_id                        ,
			@login_id                       ,
			@value_date                     ,
			@book_date                      ,
			@store_id                       ,
			@counter_id                     ,
			@customer_id                    ,
			@price_type_id                  ,
			@reference_number               ,
			@statement_reference            ,
			@details                        ,
			@shipper_id						,
			@discount						,
			@tran_master_id                 OUTPUT;
		
		RETURN;
	END;

	SELECT 
		@original_customer_id = sales.sales.customer_id,
		@original_checkout_id = sales.sales.checkout_id
	FROM sales.sales
	INNER JOIN finance.transaction_master
	ON finance.transaction_master.transaction_master_id = sales.sales.transaction_master_id
	AND finance.transaction_master.verification_status_id > 0
	AND finance.transaction_master.transaction_master_id = @transaction_master_id;

	DECLARE @new_checkout_items TABLE
	(
		store_id					integer,
		transaction_type			national character varying(2),
		item_id						integer,
		quantity					numeric(30, 6),
		unit_id						integer,
        base_quantity				numeric(30, 6),
        base_unit_id                integer,                
		price						numeric(30, 6),
		discount_rate				numeric(30, 6),
		discount					numeric(30, 6),
		shipping_charge				numeric(30, 6)
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

        SET @tax_account_id                         = finance.get_sales_tax_account_id_by_office_id(@office_id);

		
		IF(@original_customer_id IS NULL)
		BEGIN
			RAISERROR('Invalid transaction.', 16, 1);
		END;

		IF(@original_customer_id != @customer_id)
		BEGIN
			RAISERROR('This customer is not associated with the sales you are trying to return.', 16, 1);
		END;

		DECLARE @is_valid_transaction	bit;
		SELECT
			@is_valid_transaction	=	is_valid,
			@error_message			=	"error_message"
		FROM sales.validate_items_for_return(@transaction_master_id, @details);

        IF(@is_valid_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 16, 1);
            RETURN;
        END;

        SET @default_currency_code      = core.get_currency_code_by_office_id(@office_id);
        SET @tran_counter               = finance.get_new_transaction_counter(@value_date);
        SET @tran_code                  = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id);

        SELECT @sales_id = sales.sales.sales_id 
        FROM sales.sales
        WHERE sales.sales.transaction_master_id = @transaction_master_id;




		--Returned items are subtracted
		INSERT INTO @new_checkout_items(store_id, item_id, quantity, unit_id, price, discount_rate, shipping_charge)
		SELECT store_id, item_id, quantity *-1, unit_id, price *-1, ROUND(discount_rate, 2), shipping_charge *-1
		FROM @details;
	
		--Original items are added
		INSERT INTO @new_checkout_items(store_id, item_id, quantity, unit_id, price, discount_rate, shipping_charge)
		SELECT 
			inventory.checkout_details.store_id, 
			inventory.checkout_details.item_id,
			inventory.checkout_details.quantity,
			inventory.checkout_details.unit_id,
			inventory.checkout_details.price,
			ROUND(inventory.checkout_details.discount_rate, 2),
			inventory.checkout_details.shipping_charge
		FROM inventory.checkout_details
		WHERE checkout_id = @original_checkout_id;

		UPDATE @new_checkout_items 
		SET
			base_quantity                   = inventory.get_base_quantity_by_unit_id(unit_id, quantity),
			base_unit_id                    = inventory.get_root_unit_id(unit_id),
			discount                        = ROUND(((price * quantity) + shipping_charge) * (discount_rate / 100), 2);
	

		IF EXISTS
		(
			SELECT item_id, COUNT(DISTINCT unit_id) 
			FROM @new_checkout_items
			GROUP BY item_id
			HAVING COUNT(DISTINCT unit_id) > 1
		)
		BEGIN
			RAISERROR('A return entry must exactly macth the unit of measure provided during sales.', 16, 1);
		END;
	
		IF EXISTS
		(
			SELECT item_id, COUNT(DISTINCT ABS(price))
			FROM @new_checkout_items
			GROUP BY item_id
			HAVING COUNT(DISTINCT ABS(price)) > 1
		)
		BEGIN
			RAISERROR('A return entry must exactly macth the price provided during sales.', 16, 1);
		END;
	
		
	
		IF EXISTS
		(
			SELECT item_id, COUNT(DISTINCT store_id) 
			FROM @new_checkout_items
			GROUP BY item_id
			HAVING COUNT(DISTINCT store_id) > 1
		)
		BEGIN
			RAISERROR('A return entry must exactly macth the store provided during sales.', 16, 1);
		END;


		INSERT INTO @difference(store_id, transaction_type, item_id, quantity, unit_id, price, discount, shipping_charge)
		SELECT store_id, 'Cr', item_id, SUM(quantity), unit_id, SUM(price), SUM(discount), SUM(shipping_charge)
		FROM @new_checkout_items
		GROUP BY store_id, item_id, unit_id;
			
		DELETE FROM @difference
		WHERE quantity = 0;

		--> REVERSE THE ORIGINAL TRANSACTION
        INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference)
		SELECT @tran_counter, @tran_code, @book_name, @value_date, @book_date, @user_id, @login_id, @office_id, @cost_center_id, @reference_number, @statement_reference;

		SET @reversal_tran_id = SCOPE_IDENTITY();

		INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, er, local_currency_code, amount_in_local_currency)
		SELECT 
			@reversal_tran_id, 
			office_id, 
			value_date, 
			book_date, 
			CASE WHEN tran_type = 'Dr' THEN 'Cr' ELSE 'Dr' END, 
			account_id, 
			@statement_reference, 
			currency_code, 
			amount_in_currency, 
			er, 
			local_currency_code, 
			amount_in_local_currency
		FROM finance.transaction_details
		WHERE finance.transaction_details.transaction_master_id = @transaction_master_id;

		IF EXISTS(SELECT * FROM @difference)
		BEGIN
			--> ADD A NEW SALES INVOICE
			EXECUTE sales.post_sales
				@office_id,
				@user_id,
				@login_id,
				@counter_id,
				@value_date,
				@book_date,
				@cost_center_id,
				@reference_number,
				@statement_reference,
				NULL, --@tender,
				NULL, --@change,
				NULL, --@payment_term_id,
				NULL, --@check_amount,
				NULL, --@check_bank_name,
				NULL, --@check_number,
				NULL, --@check_date,
				NULL, --@gift_card_number,
				@customer_id,
				@price_type_id,
				@shipper_id,
				@store_id,
				NULL, --@coupon_code,
				1, --@is_flat_discount,
				@discount,
				@difference,
				NULL, --@sales_quotation_id,
				NULL, --@sales_order_id,
				NULL, --@serial_number_ids
				@new_tran_id  OUTPUT,
				@book_name;
		END;
		ELSE
		BEGIN
			SET @tran_counter               = finance.get_new_transaction_counter(@value_date);
			SET @tran_code                  = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id);

			INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference)
			SELECT @tran_counter, @tran_code, @book_name, @value_date, @book_date, @user_id, @login_id, @office_id, @cost_center_id, @reference_number, @statement_reference;

			SET @new_tran_id = SCOPE_IDENTITY();
		END;

		INSERT INTO inventory.checkouts(transaction_book, value_date, book_date, transaction_master_id, office_id, posted_by, discount, taxable_total, tax_rate, tax, nontaxable_total) 
		SELECT @book_name, @value_date, @book_date, @new_tran_id, office_id, @user_id, discount, taxable_total, tax_rate, tax, nontaxable_total
		FROM inventory.checkouts
		WHERE inventory.checkouts.checkout_id = @original_checkout_id;

		SET @checkout_id = SCOPE_IDENTITY();

        INSERT INTO inventory.checkout_details(value_date, book_date, checkout_id, transaction_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, is_taxed, cost_of_goods_sold, discount)
		SELECT @value_date, @book_date, @checkout_id, 
		CASE WHEN transaction_type = 'Dr' THEN 'Cr' ELSE 'Dr' END, 
		store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, is_taxed, cost_of_goods_sold, discount
		FROM inventory.checkout_details
		WHERE inventory.checkout_details.checkout_id = @original_checkout_id;

		INSERT INTO sales.returns(sales_id, checkout_id, transaction_master_id, return_transaction_master_id, counter_id, customer_id, price_type_id)
		SELECT @sales_id, @checkout_id, @transaction_master_id, @new_tran_id, @counter_id, @customer_id, @price_type_id;

		SET @tran_master_id = @new_tran_id;

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
--DECLARE @store_id                       integer = (SELECT TOP 1 store_id FROM inventory.stores WHERE store_name='Cold Room RM');
--DECLARE @counter_id                     integer = (SELECT TOP 1 counter_id FROM inventory.counters WHERE counter_name = 'Counter 2');
--DECLARE @customer_id                    integer = (SELECT customer_id FROM inventory.customers WHERE customer_name = 'Ajima Mart');
--DECLARE @price_type_id                  integer = (SELECT TOP 1 price_type_id FROM sales.price_types);
--DECLARE @reference_number               national character varying(24) = 'N/A';
--DECLARE @statement_reference            national character varying(2000) = 'Test';
--DECLARE @details                        sales.sales_detail_type;
--DECLARE @tran_master_id                 bigint;

--INSERT INTO @details(store_id, transaction_type, item_id, quantity, unit_id, price, discount, shipping_charge, is_taxed)
--SELECT @store_id, 'Cr', 1, 1, 1, 2320, 62.84, 0, 1;


--EXECUTE sales.post_return
--    @transaction_master_id          ,
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











