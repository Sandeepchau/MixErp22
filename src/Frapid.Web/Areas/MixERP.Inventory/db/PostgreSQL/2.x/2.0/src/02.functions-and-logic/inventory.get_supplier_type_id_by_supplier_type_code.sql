DROP FUNCTION IF EXISTS inventory.get_supplier_type_id_by_supplier_type_code(text);

CREATE FUNCTION inventory.get_supplier_type_id_by_supplier_type_code(text)
RETURNS integer
STABLE
AS
$$
BEGIN
    RETURN supplier_type_id
    FROM inventory.supplier_types
    WHERE inventory.supplier_types.supplier_type_code=$1
	AND NOT inventory.supplier_types.deleted;
END
$$
LANGUAGE plpgsql;
