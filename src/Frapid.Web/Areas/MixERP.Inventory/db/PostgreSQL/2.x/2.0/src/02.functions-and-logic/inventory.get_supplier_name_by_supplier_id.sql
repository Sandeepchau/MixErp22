DROP FUNCTION IF EXISTS inventory.get_supplier_name_by_supplier_id(_supplier_id integer);

CREATE FUNCTION inventory.get_supplier_name_by_supplier_id(_supplier_id integer)
RETURNS national character varying(500)
AS
$$
BEGIN
    RETURN inventory.suppliers.supplier_name
    FROM inventory.suppliers
    WHERE inventory.suppliers.supplier_id = _supplier_id;
END
$$
LANGUAGE plpgsql;
