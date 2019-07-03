DROP FUNCTION IF EXISTS sales.get_receivable_account_for_check_receipts(_store_id integer);

CREATE FUNCTION sales.get_receivable_account_for_check_receipts(_store_id integer)
RETURNS integer
AS
$$
BEGIN
    RETURN inventory.stores.default_account_id_for_checks
    FROM inventory.stores
    WHERE inventory.stores.store_id = _store_id
    AND NOT inventory.stores.deleted;
END
$$
LANGUAGE plpgsql;

