DROP FUNCTION IF EXISTS inventory.get_account_id_by_supplier_type_id(_supplier_type_id integer);

CREATE FUNCTION inventory.get_account_id_by_supplier_type_id(_supplier_type_id integer)
RETURNS integer
STABLE
AS
$$
BEGIN
    RETURN account_id
    FROM inventory.supplier_types
    WHERE supplier_type_id=_supplier_type_id;
END;
$$
LANGUAGE plpgsql;

--SELECT * FROM inventory.get_account_id_by_supplier_type_id(1);