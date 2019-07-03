IF OBJECT_ID('sales.add_gift_card_fund') IS NOT NULL
DROP PROCEDURE sales.add_gift_card_fund;

GO

CREATE PROCEDURE sales.add_gift_card_fund
(
    @user_id                                    integer, 
    @office_id                                  integer, 
    @login_id                                   bigint,
    @gift_card_number                           national character varying(500),
    @value_date                                 date,
    @book_date                                  date,
    @debit_account_id                           integer,
    @amount                                     numeric(30, 6),
    @cost_center_id                             integer,
    @reference_number                           national character varying(24), 
    @statement_reference                        national character varying(2000)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

	DECLARE @gift_card_id						integer;

	SELECT TOP 1 @gift_card_id = sales.gift_cards.gift_card_id
	FROM sales.gift_cards
	WHERE sales.gift_cards.gift_card_number = @gift_card_number
	AND sales.gift_cards.deleted = 0;

    DECLARE @transaction_master_id              bigint;
    DECLARE @book_name                          national character varying(50) = 'Gift Card Fund Sales';
    DECLARE @payable_account_id                 integer = sales.get_payable_account_id_by_gift_card_id(@gift_card_id);
    DECLARE @currency_code                      national character varying(12) = core.get_currency_code_by_office_id(@office_id);


    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
        
        INSERT INTO finance.transaction_master(transaction_counter, transaction_code, book, value_date, book_date, login_id, user_id, office_id, cost_center_id, reference_number, statement_reference)
        SELECT
            finance.get_new_transaction_counter(@value_date),
            finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id),
            @book_name,
            @value_date,
            @book_date,
            @login_id,
            @user_id,
            @office_id,
            @cost_center_id,
            @reference_number,
            @statement_reference;

        SET @transaction_master_id = SCOPE_IDENTITY();

        INSERT INTO finance.transaction_details(transaction_master_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, office_id, audit_user_id)
        SELECT
            @transaction_master_id, 
            @value_date, 
            @book_date,
            'Cr', 
            @payable_account_id, 
            @statement_reference, 
            @currency_code, 
            @amount, 
            @currency_code, 
            1, 
            @amount, 
            @office_id, 
            @user_id;

        INSERT INTO finance.transaction_details(transaction_master_id, value_date, book_date, tran_type, account_id, statement_reference, currency_code, amount_in_currency, local_currency_code, er, amount_in_local_currency, office_id, audit_user_id)
        SELECT
            @transaction_master_id, 
            @value_date, 
            @book_date,
            'Dr', 
            @debit_account_id, 
            @statement_reference, 
            @currency_code, 
            @amount, 
            @currency_code, 
            1, 
            @amount, 
            @office_id, 
            @user_id;

        INSERT INTO sales.gift_card_transactions(gift_card_id, value_date, book_date, transaction_master_id, transaction_type, amount)
        SELECT @gift_card_id, @value_date, @book_date, @transaction_master_id, 'Cr', @amount;

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
