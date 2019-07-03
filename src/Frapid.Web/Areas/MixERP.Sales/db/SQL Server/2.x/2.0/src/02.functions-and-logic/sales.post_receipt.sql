IF OBJECT_ID('sales.post_receipt') IS NOT NULL
DROP PROCEDURE sales.post_receipt;

GO

CREATE PROCEDURE sales.post_receipt
(
    @user_id                                    integer, 
    @office_id                                  integer, 
    @login_id                                   bigint,
    
    @customer_id                                integer,
    @currency_code                              national character varying(12), 
    @exchange_rate_debit                        numeric(30, 6), 

    @exchange_rate_credit                       numeric(30, 6),
    @reference_number                           national character varying(24), 
    @statement_reference                        national character varying(2000), 

    @cost_center_id                             integer,
    @cash_account_id                            integer,
    @cash_repository_id                         integer,

    @value_date                                 date,
    @book_date                                  date,
    @receipt_amount                             numeric(30, 6),

    @tender                                     numeric(30, 6),
    @change                                     numeric(30, 6),
    @check_amount                               numeric(30, 6),

    @check_bank_name                            national character varying(1000),
    @check_number                               national character varying(100),
    @check_date                                 date,

    @gift_card_number                           national character varying(100),
    @store_id                                   integer,
    @cascading_tran_id                          bigint,
    @transaction_master_id                      bigint OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @book                               national character varying(50);
    DECLARE @base_currency_code                 national character varying(12);
    DECLARE @local_currency_code                national character varying(12);
    DECLARE @customer_account_id                integer;
    DECLARE @debit                              numeric(30, 6);
    DECLARE @credit                             numeric(30, 6);
    DECLARE @lc_debit                           numeric(30, 6);
    DECLARE @lc_credit                          numeric(30, 6);
    DECLARE @is_cash                            bit;
    DECLARE @gift_card_id                       integer;
    DECLARE @receivable_account_id              integer;
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

        IF(@cash_repository_id > 0 AND @cash_account_id > 0)
        BEGIN
            SET @is_cash                            = 1;
        END;

        SET @receivable_account_id                  = sales.get_receivable_account_for_check_receipts(@store_id);
        SET @gift_card_id                           = sales.get_gift_card_id_by_gift_card_number(@gift_card_number);
        SET @customer_account_id                    = inventory.get_account_id_by_customer_id(@customer_id);    
        SET @local_currency_code                    = core.get_currency_code_by_office_id(@office_id);
        SET @base_currency_code                     = inventory.get_currency_code_by_customer_id(@customer_id);


        IF(@local_currency_code = @currency_code AND @exchange_rate_debit != 1)
        BEGIN
            RAISERROR('Invalid exchange rate.', 13, 1);
        END;

        IF(@base_currency_code = @currency_code AND @exchange_rate_credit != 1)
        BEGIN
            RAISERROR('Invalid exchange rate.', 13, 1);
        END;

        
        IF(@tender >= @receipt_amount)
        BEGIN
            EXECUTE sales.post_cash_receipt @user_id, @office_id, @login_id, @customer_id, @customer_account_id, @currency_code, @local_currency_code, @base_currency_code, @exchange_rate_debit, @exchange_rate_credit, @reference_number, @statement_reference, @cost_center_id, @cash_account_id, @cash_repository_id, @value_date, @book_date, @receipt_amount, @tender, @change, @cascading_tran_id,
            @transaction_master_id = @transaction_master_id OUTPUT;
        END
        ELSE IF(@check_amount >= @receipt_amount)
        BEGIN
            EXECUTE sales.post_check_receipt @user_id, @office_id, @login_id, @customer_id, @customer_account_id, @receivable_account_id, @currency_code, @local_currency_code, @base_currency_code, @exchange_rate_debit, @exchange_rate_credit, @reference_number, @statement_reference, @cost_center_id, @value_date, @book_date, @check_amount, @check_bank_name, @check_number, @check_date, @cascading_tran_id,
            @transaction_master_id = @transaction_master_id OUTPUT;
        END
        ELSE IF(@gift_card_id > 0)
        BEGIN
            EXECUTE sales.post_receipt_by_gift_card @user_id, @office_id, @login_id, @customer_id, @customer_account_id, @currency_code, @local_currency_code, @base_currency_code, @exchange_rate_debit, @exchange_rate_credit, @reference_number, @statement_reference, @cost_center_id, @value_date, @book_date, @gift_card_id, @gift_card_number, @receipt_amount, @cascading_tran_id,
            @transaction_master_id = @transaction_master_id OUTPUT;
        END
        ELSE
        BEGIN
            RAISERROR('Cannot post receipt. Please enter the tender amount.', 13, 1);
        END;

        
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
END;


GO

