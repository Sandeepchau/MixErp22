DROP FUNCTION IF EXISTS inventory.get_store_id_by_store_code(_store_code text);

CREATE FUNCTION inventory.get_store_id_by_store_code(_store_code text)
RETURNS integer
STABLE
AS
$$
BEGIN
    RETURN
    (
        SELECT inventory.stores.store_id
        FROM inventory.stores
        WHERE inventory.stores.store_code=_store_code 
        AND NOT inventory.stores.deleted
    );
END
$$
LANGUAGE plpgsql;

