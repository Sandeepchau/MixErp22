IF OBJECT_ID('inventory.is_purchase') IS NOT NULL
DROP FUNCTION inventory.is_purchase;

GO

CREATE FUNCTION inventory.is_purchase(@transaction_master_id bigint)
RETURNS bit
AS

BEGIN
    IF EXISTS
    (
        SELECT * FROM finance.transaction_master
        WHERE finance.transaction_master.transaction_master_id = @transaction_master_id
        AND book IN ('Purchase')
    )
    BEGIN
            RETURN 1;
    END;

    RETURN 0;
END;




GO
