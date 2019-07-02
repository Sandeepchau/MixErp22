DROP FUNCTION IF EXISTS inventory.get_store_name_by_store_id(integer);
CREATE OR REPLACE FUNCTION inventory.get_store_name_by_store_id(integer)
  RETURNS text AS
$$
BEGIN
    RETURN store_name
    FROM inventory.stores
    WHERE inventory.stores.store_id = $1
	AND NOT inventory.stores.deleted;
END
$$
  LANGUAGE plpgsql;