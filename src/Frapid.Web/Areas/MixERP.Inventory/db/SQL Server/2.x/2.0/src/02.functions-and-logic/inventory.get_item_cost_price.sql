-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.x/2.0/src/02.functions-and-logic/inventory.get_item_cost_price.sql --<--<--
IF OBJECT_ID('inventory.get_item_cost_price') IS NOT NULL
DROP FUNCTION inventory.get_item_cost_price;

GO

CREATE FUNCTION inventory.get_item_cost_price(@item_id integer, @unit_id integer)
RETURNS numeric(30, 6)
AS  
BEGIN    
    DECLARE @price              numeric(30, 6);
    DECLARE @costing_unit_id    integer;
    DECLARE @factor             numeric(30, 6);

    SELECT 
        @price = cost_price, 
        @costing_unit_id = unit_id
    FROM inventory.items
    WHERE inventory.items.item_id = @item_id
    AND inventory.items.deleted = 0;

    --Get the unitary conversion factor if the requested unit does not match with the price defition.
    SET @factor = inventory.convert_unit(@unit_id, @costing_unit_id);
    RETURN @price * @factor;
END;



--SELECT * FROM inventory.get_item_cost_price(6, 7);


GO
