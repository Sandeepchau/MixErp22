DROP FUNCTION IF EXISTS inventory.get_supplier_id_by_supplier_code(text);

CREATE FUNCTION inventory.get_supplier_id_by_supplier_code(text)
RETURNS integer
AS
$$
BEGIN
        RETURN supplier_id
        FROM inventory.suppliers
        WHERE inventory.suppliers.supplier_code=$1
		AND NOT inventory.suppliers.deleted;
END
$$
LANGUAGE plpgsql;
