IF OBJECT_ID('sales.add_opening_cash') IS NOT NULL
DROP PROCEDURE sales.add_opening_cash;

GO

CREATE PROCEDURE sales.add_opening_cash
(
    @user_id                                integer,
    @transaction_date                       DATETIMEOFFSET,
    @amount                                 numeric(30, 6),
    @provided_by                            national character varying(1000),
    @memo                                   national character varying(4000)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sales.opening_cash
        WHERE user_id = @user_id
        AND transaction_date = @transaction_date
    )
    BEGIN
        INSERT INTO sales.opening_cash(user_id, transaction_date, amount, provided_by, memo, audit_user_id, audit_ts, deleted)
        SELECT @user_id, @transaction_date, @amount, @provided_by, @memo, @user_id, GETUTCDATE(), 0;
    END
    ELSE
    BEGIN
        UPDATE sales.opening_cash
        SET
            amount = @amount,
            provided_by = @provided_by,
            memo = @memo,
            user_id = @user_id,
            audit_user_id = @user_id,
            audit_ts = GETUTCDATE(),
            deleted = 0
        WHERE user_id = @user_id
        AND transaction_date = @transaction_date;
    END;
END

GO

