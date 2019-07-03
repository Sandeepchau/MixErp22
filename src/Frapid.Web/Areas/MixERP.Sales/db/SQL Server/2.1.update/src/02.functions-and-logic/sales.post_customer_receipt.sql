IF OBJECT_ID('sales.post_customer_receipt') IS NOT NULL
DROP PROCEDURE sales.post_customer_receipt;

GO

CREATE PROCEDURE sales.post_customer_receipt
(
	@value_date									date,
	@book_date									date,
    @user_id                                    integer, 
    @office_id                                  integer, 
    @login_id                                   bigint,
    @customer_id                                integer, 
    @currency_code                              national character varying(12),
    @cash_account_id                            integer,
    @amount                                     numeric(30, 6), 
    @exchange_rate_debit                        numeric(30, 6), 
    @exchange_rate_credit                       numeric(30, 6),
    @reference_number                           national character varying(24), 
    @statement_reference                        national character varying(128), 
    @cost_center_id                             integer,
    @cash_repository_id                         integer,
    @posted_date                                date,
    @bank_id									integer,
    @payment_card_id                            integer,
    @bank_instrument_code                       national character varying(128),
    @bank_tran_code                             national character varying(128),
    @transaction_master_id						bigint OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

	DECLARE @bank_account_id					integer = finance.get_account_id_by_bank_account_id(@bank_id);
    DECLARE @book                               national character varying(50);
    DECLARE @base_currency_code                 national character varying(12);
    DECLARE @local_currency_code                national character varying(12);
    DECLARE @customer_account_id                integer;
    DECLARE @debit                              numeric(30, 6);
    DECLARE @credit                             numeric(30, 6);
    DECLARE @lc_debit                           numeric(30, 6);
    DECLARE @lc_credit                          numeric(30, 6);
    DECLARE @is_cash                            bit;
    DECLARE @is_merchant                        bit=0;
    DECLARE @merchant_rate                      numeric(30, 6)=0;
    DECLARE @customer_pays_fee                  bit=0;
    DECLARE @merchant_fee_accont_id             integer;
    DECLARE @merchant_fee_statement_reference   national character varying(2000);
    DECLARE @merchant_fee                       numeric(30, 6);
    DECLARE @merchant_fee_lc                    numeric(30, 6);
    DECLARE @can_post_transaction               bit;
    DECLARE @error_message                      national character varying(MAX);

    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
        
        SELECT
            @can_post_transaction   = can_post_transaction,
            @error_message          = error_message
        FROM finance.can_post_transaction(@login_id, @user_id, @office_id, @book, @value_date);

        IF(@can_post_transaction = 0)
        BEGIN
            RAISERROR(@error_message, 13, 1);
            RETURN;
        END;

		IF(@cash_repository_id > 0)
		BEGIN
			IF(@posted_date IS NOT NULL OR @bank_id IS NOT NULL OR COALESCE(@bank_instrument_code, '') != '' OR COALESCE(@bank_tran_code, '') != '')
			BEGIN
				RAISERROR('Invalid bank transaction information provided.', 16, 1);
			END;

			SET @is_cash = 1;
		END;

		SET @book								= 'Sales Receipt';
    
		SET @customer_account_id				= inventory.get_account_id_by_customer_id(@customer_id);    
		SET @local_currency_code                = core.get_currency_code_by_office_id(@office_id);
		SET @base_currency_code                 = inventory.get_currency_code_by_customer_id(@customer_id);


		IF EXISTS
		(
			SELECT 1 FROM finance.bank_accounts
			WHERE is_merchant_account = 1
			AND bank_account_id = @bank_id
		)
		BEGIN
			SET @is_merchant = 1;
		END;

		SELECT 
			@merchant_rate						= rate,
			@customer_pays_fee					= customer_pays_fee,
			@merchant_fee_accont_id				=	account_id,
			@merchant_fee_statement_reference	= statement_reference
		FROM finance.merchant_fee_setup
		WHERE merchant_account_id = @bank_id
		AND payment_card_id = @payment_card_id;

		SET @merchant_rate		= COALESCE(@merchant_rate, 0);
		SET @customer_pays_fee  = COALESCE(@customer_pays_fee, 0);

		IF(@is_merchant = 1 AND COALESCE(@payment_card_id, 0) = 0)
		BEGIN
			RAISERROR('Invalid payment card information.', 16, 1);
		END;

		IF(@merchant_rate > 0 AND COALESCE(@merchant_fee_accont_id, 0) = 0)
		BEGIN
			RAISERROR('Could not find an account to post merchant fee expenses.', 16, 1);
		END;

		IF(@local_currency_code = @currency_code AND @exchange_rate_debit != 1)
		BEGIN
			RAISERROR('Invalid exchange rate.', 16, 1);
		END;

		IF(@base_currency_code = @currency_code AND @exchange_rate_credit != 1)
		BEGIN
			RAISERROR('Invalid exchange rate.', 16, 1);
		END ;
        
		SET @debit								= @amount;
		SET @lc_debit							= @amount * @exchange_rate_debit;

		SET @credit                             = @amount * (@exchange_rate_debit/ @exchange_rate_credit);
		SET @lc_credit                          = @amount * @exchange_rate_debit;
		SET @merchant_fee                       = (@debit * @merchant_rate) / 100;
		SET @merchant_fee_lc                    = (@lc_debit * @merchant_rate)/100;
    
		INSERT INTO finance.transaction_master
		(
			transaction_counter, 
			transaction_code, 
			book, 
			value_date, 
			book_date, 
			user_id, 
			login_id, 
			office_id, 
			cost_center_id, 
			reference_number, 
			statement_reference
		)
		SELECT 
			finance.get_new_transaction_counter(@value_date), 
			finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id),
			@book,
			@value_date,
			@book_date,
			@user_id,
			@login_id,
			@office_id,
			@cost_center_id,
			@reference_number,
			@statement_reference;

		SET @transaction_master_id = SCOPE_IDENTITY();
		--Debit
		IF(@is_cash = 1)
		BEGIN
			INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
			SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @cash_account_id, @statement_reference, @cash_repository_id, @currency_code, @debit, @local_currency_code, @exchange_rate_debit, @lc_debit, @user_id;
		END
		ELSE
		BEGIN
			INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
			SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @bank_account_id, @statement_reference, NULL, @currency_code, @debit, @local_currency_code, @exchange_rate_debit, @lc_debit, @user_id;        
		END;

		--Credit
		INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
		SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @customer_account_id, @statement_reference, NULL, @base_currency_code, @credit, @local_currency_code, @exchange_rate_credit, @lc_credit, @user_id;


		IF(@is_merchant = 1 AND @merchant_rate > 0 AND @merchant_fee_accont_id > 0)
		BEGIN
			--Debit: Merchant Fee Expenses
			INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
			SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @merchant_fee_accont_id, @merchant_fee_statement_reference, NULL, @currency_code, @merchant_fee, @local_currency_code, @exchange_rate_debit, @merchant_fee_lc, @user_id;

			--Credit: Merchant A/C
			INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
			SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @bank_account_id, @merchant_fee_statement_reference, NULL, @currency_code, @merchant_fee, @local_currency_code, @exchange_rate_debit, @merchant_fee_lc, @user_id;

			IF(@customer_pays_fee = 1)
			BEGIN
				--Debit: Party Account Id
				INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
				SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @customer_account_id, @merchant_fee_statement_reference, NULL, @currency_code, @merchant_fee, @local_currency_code, @exchange_rate_debit, @merchant_fee_lc, @user_id;

				--Credit: Reverse Merchant Fee Expenses
				INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
				SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @merchant_fee_accont_id, @merchant_fee_statement_reference, NULL, @currency_code, @merchant_fee, @local_currency_code, @exchange_rate_debit, @merchant_fee_lc, @user_id;
			END;
		END;
    
    
		INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, amount, er_debit, er_credit, cash_repository_id, posted_date, collected_on_bank_id, collected_bank_instrument_code, collected_bank_transaction_code)
		SELECT @transaction_master_id, @customer_id, @currency_code, @amount,  @exchange_rate_debit, @exchange_rate_credit, @cash_repository_id, @posted_date, @bank_id, @bank_instrument_code, @bank_tran_code;

		EXECUTE finance.auto_verify @transaction_master_id, @office_id;
		EXECUTE sales.settle_customer_due @customer_id, @office_id;

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
END

GO

 
-- EXECUTE sales.post_customer_receipt
 
--     1, --@user_id                                    integer, 
--     1, --@office_id                                  integer, 
--     1, --_login_id                                   bigint,
--     1, --_customer_id                                integer, 
--     'USD', --@currency_code                              national character varying(12), 
--     1,--    @cash_account_id                            integer,
--     100, --_amount                                     public.money_strict, 
--     1, --@exchange_rate_debit                        public.decimal_strict, 
--     1, --@exchange_rate_credit                       public.decimal_strict,
--     '', --_reference_number                           national character varying(24), 
--     '', --@statement_reference                        national character varying(128), 
--     1, --_cost_center_id                             integer,
--     1, --@cash_repository_id                         integer,
--     NULL, --_posted_date                                date,
--     NULL, --@bank_account_id                            bigint,
--     NULL, --_payment_card_id                            integer,
--     NULL, -- _bank_instrument_code                       national character varying(128),
--     NULL, -- _bank_tran_code                             national character varying(128),
--	 NULL
--;