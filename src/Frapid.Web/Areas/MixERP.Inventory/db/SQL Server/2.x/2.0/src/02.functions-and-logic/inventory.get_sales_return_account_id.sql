IF OBJECT_ID('inventory.get_sales_return_account_id') IS NOT NULL
DROP FUNCTION inventory.get_sales_return_account_id;

GO

CREATE FUNCTION inventory.get_sales_return_account_id(@item_id integer)
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT inventory.item_groups.sales_return_account_id
	    FROM inventory.item_groups
	    INNER JOIN inventory.items
	    ON inventory.item_groups.item_group_id = inventory.items.item_group_id
	    WHERE inventory.items.item_id = @item_id
	    AND inventory.item_groups.deleted = 0
    );
END;





GO
