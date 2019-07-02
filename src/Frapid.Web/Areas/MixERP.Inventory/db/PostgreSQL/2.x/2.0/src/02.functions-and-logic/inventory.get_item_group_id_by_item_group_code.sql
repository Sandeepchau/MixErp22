DROP FUNCTION IF EXISTS inventory.get_item_group_id_by_item_group_code(text);

CREATE FUNCTION inventory.get_item_group_id_by_item_group_code(text)
RETURNS integer
AS
$$
BEGIN
        RETURN item_group_id
        FROM inventory.item_groups
        WHERE inventory.item_groups.item_group_code=$1
		AND NOT inventory.item_groups.deleted;
END
$$
LANGUAGE plpgsql;
