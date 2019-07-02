DROP FUNCTION IF EXISTS inventory.get_account_id_by_supplier_id(_supplier_id integer);

CREATE FUNCTION inventory.get_account_id_by_supplier_id(_supplier_id integer)
RETURNS integer
AS
$$
BEGIN
    RETURN
        inventory.suppliers.account_id
    FROM inventory.suppliers
    WHERE inventory.suppliers.supplier_id = _supplier_id
    AND NOT inventory.suppliers.deleted;
END
$$
LANGUAGE plpgsql;

