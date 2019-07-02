DROP FUNCTION IF EXISTS inventory.get_cash_repository_id_by_store_id(_store_id integer);

CREATE FUNCTION inventory.get_cash_repository_id_by_store_id(_store_id integer)
RETURNS bigint
STABLE
AS
$$
BEGIN
    RETURN inventory.stores.default_cash_repository_id
    FROM inventory.stores
    WHERE inventory.stores.store_id=_store_id
    AND NOT inventory.stores.deleted;
END
$$
LANGUAGE plpgsql;

