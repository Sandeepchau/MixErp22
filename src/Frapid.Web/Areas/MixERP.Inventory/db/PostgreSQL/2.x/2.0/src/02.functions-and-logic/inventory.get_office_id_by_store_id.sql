DROP FUNCTION IF EXISTS inventory.get_office_id_by_store_id(integer);

CREATE FUNCTION inventory.get_office_id_by_store_id(integer)
RETURNS integer
AS
$$
BEGIN
    RETURN inventory.stores.office_id
    FROM inventory.stores
    WHERE inventory.stores.store_id=$1
	AND NOT inventory.stores.deleted;
END
$$
LANGUAGE plpgsql;
