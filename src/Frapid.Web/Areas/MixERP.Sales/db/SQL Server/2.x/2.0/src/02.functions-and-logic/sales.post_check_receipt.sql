IF OBJECT_ID('sales.post_check_receipt') IS NOT NULL
DROP PROCEDURE sales.post_check_receipt;

GO

CREATE PROCEDURE sales.post_check_receipt
(
    @user_id                                    integer, 
    @office_id                                  integer, 
    @login_id                                   bigint,
    @customer_id                                integer,
    @customer_account_id                        integer,
    @receivable_account_id                      integer,--sales.get_receivable_account_for_check_receipts(@store_id)
    @currency_code                              national character varying(12),
    @local_currency_code                        national character varying(12),
    @base_currency_code                         national character varying(12),
    @exchange_rate_debit                        numeric(30, 6), 
    @exchange_rate_credit                       numeric(30, 6),
    @reference_number                           national character varying(24), 
    @statement_reference                        national character varying(2000), 
    @cost_center_id                             integer,
    @value_date                                 date,
    @book_date                                  date,
    @check_amount                               numeric(30, 6),
    @check_bank_name                            national character varying(1000),
    @check_number                               national character varying(100),
    @check_date                                 date,
    @cascading_tran_id                          bigint,
    @transaction_master_id                      bigint OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @book                               national character varying(50) = 'Sales Receipt';
    DECLARE @debit                              numeric(30, 6);
    DECLARE @credit                             numeric(30, 6);
    DECLARE @lc_debit                           numeric(30, 6);
    DECLARE @lc_credit                          numeric(30, 6);
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

        SET @debit                                  = @check_amount;
        SET @lc_debit                               = @check_amount * @exchange_rate_debit;

        SET @credit                                 = @check_amount * (@exchange_rate_debit/ @exchange_rate_credit);
        SET @lc_credit                              = @check_amount * @exchange_rate_debit;
        
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
            statement_reference,
            audit_user_id,
            cascading_tran_id
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
            @statement_reference,
            @user_id,
            @cascading_tran_id;

        SET @transaction_master_id = SCOPE_IDENTITY();


        --Debit
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
        SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @receivable_account_id, @statement_reference, NULL, @currency_code, @debit, @local_currency_code, @exchange_rate_debit, @lc_debit, @user_id;        

        --Credit
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date, book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
        SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @customer_account_id, @statement_reference, NULL, @base_currency_code, @credit, @local_currency_code, @exchange_rate_credit, @lc_credit, @user_id;
        
        
        INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, posted_date, check_amount, check_bank_name, check_number, check_date, amount)
        SELECT @transaction_master_id, @customer_id, @currency_code, @exchange_rate_debit, @exchange_rate_credit, @value_date, @check_amount, @check_bank_name, @check_number, @check_date, @check_amount;

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

--SELECT * FROM sales.post_check_receipt(1, 1, 1, 1, 1, 1, 'USD', 'USD', 'USD', 1, 1, '', '', 1, '1-1-2020', '1-1-2020', 2000, '', '', '1-1-2020', null);
