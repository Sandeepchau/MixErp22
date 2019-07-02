DROP FUNCTION IF EXISTS inventory.get_store_type_id_by_store_type_code(text);

CREATE FUNCTION inventory.get_store_type_id_by_store_type_code(text)
RETURNS integer
STABLE
AS
$$
BEGIN
    RETURN store_type_id
    FROM inventory.store_types
    WHERE inventory.store_types.store_type_code=$1
	AND NOT inventory.store_types.deleted;
END
$$
LANGUAGE plpgsql;
