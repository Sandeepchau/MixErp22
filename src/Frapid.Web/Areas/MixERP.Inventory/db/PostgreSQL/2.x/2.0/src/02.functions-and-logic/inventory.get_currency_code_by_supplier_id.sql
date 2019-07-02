DROP FUNCTION IF EXISTS inventory.get_currency_code_by_supplier_id(_supplier_id integer);

CREATE FUNCTION inventory.get_currency_code_by_supplier_id(_supplier_id integer)
RETURNS national character varying(12)
AS
$$
BEGIN
    RETURN inventory.suppliers.currency_code
    FROM inventory.suppliers
    WHERE inventory.suppliers.supplier_id = _supplier_id
    AND NOT inventory.suppliers.deleted;
END
$$
LANGUAGE plpgsql;