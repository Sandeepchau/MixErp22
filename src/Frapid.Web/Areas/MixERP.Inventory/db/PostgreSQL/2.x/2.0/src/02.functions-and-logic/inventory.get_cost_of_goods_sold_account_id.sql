DROP FUNCTION IF EXISTS inventory.get_cost_of_goods_sold_account_id(_item_id integer);

CREATE FUNCTION inventory.get_cost_of_goods_sold_account_id(_item_id integer)
RETURNS integer
STABLE
AS
$$
BEGIN
    RETURN
        cost_of_goods_sold_account_id
    FROM inventory.item_groups
    INNER JOIN inventory.items
    ON inventory.item_groups.item_group_id = inventory.items.item_group_id
    WHERE inventory.items.item_id = $1
	AND NOT inventory.item_groups.deleted;    
END
$$
LANGUAGE plpgsql;

--SELECT inventory.get_cost_of_goods_sold_account_id(1);