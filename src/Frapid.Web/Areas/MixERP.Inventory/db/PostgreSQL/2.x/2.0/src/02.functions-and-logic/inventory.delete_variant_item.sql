DROP FUNCTION IF EXISTS inventory.delete_variant_item(_item_id integer);

CREATE FUNCTION inventory.delete_variant_item(_item_id integer)
RETURNS boolean
AS
$$
BEGIN
    DELETE FROM inventory.item_variants WHERE item_id = _item_id;
    DELETE FROM inventory.items WHERE item_id = _item_id;
    RETURN true;
END
$$
LANGUAGE plpgsql;