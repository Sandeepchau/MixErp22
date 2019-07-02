DROP FUNCTION IF EXISTS inventory.get_item_type_id_by_item_type_code(text);

CREATE FUNCTION inventory.get_item_type_id_by_item_type_code(text)
RETURNS integer
AS
$$
BEGIN
        RETURN item_type_id
        FROM inventory.item_types
        WHERE inventory.item_types.item_type_code=$1
		AND NOT inventory.item_types.deleted;
END
$$
LANGUAGE plpgsql;
