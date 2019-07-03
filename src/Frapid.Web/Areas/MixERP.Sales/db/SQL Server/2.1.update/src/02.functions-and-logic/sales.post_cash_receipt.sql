IF OBJECT_ID('sales.post_cash_receipt') IS NOT NULL
DROP PROCEDURE sales.post_cash_receipt;

GO

CREATE PROCEDURE sales.post_cash_receipt
(
    @user_id                                    integer, 
    @office_id                                  integer, 
    @login_id                                   bigint,
    @customer_id                                integer,
    @customer_account_id                        integer,
    @currency_code                              national character varying(12),
    @local_currency_code                        national character varying(12),
    @base_currency_code                         national character varying(12),
    @exchange_rate_debit                        numeric(30, 6), 
    @exchange_rate_credit                       numeric(30, 6),
    @reference_number                           national character varying(24), 
    @statement_reference                        national character varying(2000), 
    @cost_center_id                             integer,
    @cash_account_id                            integer,
    @cash_repository_id                         integer,
    @value_date                                 date,
    @book_date                                  date,
    @receivable                                 numeric(30, 6),
    @tender                                     numeric(30, 6),
    @change                                     numeric(30, 6),
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

        IF(@tender < @receivable)
        BEGIN
            RAISERROR('The tendered amount must be greater than or equal to sales amount', 13, 1);
        END;
        
        SET @debit                                  = @receivable;
        SET @lc_debit                               = @receivable * @exchange_rate_debit;

        SET @credit                                 = @receivable * (@exchange_rate_debit/ @exchange_rate_credit);
        SET @lc_credit                              = @receivable * @exchange_rate_debit;

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
        SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Dr', @cash_account_id, @statement_reference, @cash_repository_id, @currency_code, @debit, @local_currency_code, @exchange_rate_debit, @lc_debit, @user_id;

        --Credit
        INSERT INTO finance.transaction_details(transaction_master_id, office_id, value_date,  book_date, tran_type, account_id, statement_reference, cash_repository_id, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, audit_user_id)
        SELECT @transaction_master_id, @office_id, @value_date, @book_date, 'Cr', @customer_account_id, @statement_reference, NULL, @base_currency_code, @credit, @local_currency_code, @exchange_rate_credit, @lc_credit, @user_id;
        
        
        INSERT INTO sales.customer_receipts(transaction_master_id, customer_id, currency_code, er_debit, er_credit, cash_repository_id, posted_date, tender, change, amount)
        SELECT @transaction_master_id, @customer_id, @currency_code, @exchange_rate_debit, @exchange_rate_credit, @cash_repository_id, @value_date, @tender, @change, @receivable;

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
