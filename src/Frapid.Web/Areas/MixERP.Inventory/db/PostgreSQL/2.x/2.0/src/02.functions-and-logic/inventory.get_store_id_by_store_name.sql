DROP FUNCTION IF EXISTS inventory.get_store_id_by_store_name(_store_name text);

CREATE FUNCTION inventory.get_store_id_by_store_name(_store_name text)
RETURNS integer
AS
$$
BEGIN
    RETURN store_id
    FROM inventory.stores
    WHERE inventory.stores.store_name = _store_name
	AND NOT inventory.stores.deleted;
END
$$
LANGUAGE plpgsql;