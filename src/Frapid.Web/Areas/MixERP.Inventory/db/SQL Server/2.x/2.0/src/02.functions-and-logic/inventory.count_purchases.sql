IF OBJECT_ID('inventory.count_purchases') IS NOT NULL
DROP FUNCTION inventory.count_purchases;

GO

CREATE FUNCTION inventory.count_purchases(@item_id integer, @unit_id integer, @store_id integer)
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @base_unit_id integer;
    DECLARE @debit numeric(30, 6);
    DECLARE @factor numeric(30, 6);

    --Get the base item unit
    SELECT @base_unit_id= inventory.get_root_unit_id(inventory.items.unit_id) 
    FROM inventory.items
    WHERE inventory.items.item_id=@item_id
    AND inventory.items.deleted = 0;

    SELECT @debit =  COALESCE(SUM(base_quantity), 0)
    FROM inventory.checkout_details
    INNER JOIN inventory.checkouts
    ON inventory.checkouts.checkout_id = inventory.checkout_details.checkout_id
    INNER JOIN finance.transaction_master
    ON inventory.checkouts.transaction_master_id = finance.transaction_master.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND inventory.checkout_details.item_id=@item_id
    AND inventory.checkout_details.store_id=@store_id
    AND inventory.checkout_details.transaction_type='Dr';

    SET @factor = inventory.convert_unit(@base_unit_id, @unit_id);    
    RETURN @debit * @factor;
END;


GO
