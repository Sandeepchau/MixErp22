IF OBJECT_ID('inventory.get_checkout_id_by_transaction_master_id') IS NOT NULL
DROP FUNCTION inventory.get_checkout_id_by_transaction_master_id;

GO

CREATE FUNCTION inventory.get_checkout_id_by_transaction_master_id(@transaction_master_id bigint)
RETURNS bigint
AS

BEGIN
    RETURN
    (
        SELECT inventory.checkouts.checkout_id
        FROM inventory.checkouts
        WHERE inventory.checkouts.transaction_master_id=@transaction_master_id
    );
END;




GO
