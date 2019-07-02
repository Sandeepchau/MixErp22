IF OBJECT_ID('inventory.get_currency_code_by_supplier_id') IS NOT NULL
DROP FUNCTION inventory.get_currency_code_by_supplier_id;

GO

CREATE FUNCTION inventory.get_currency_code_by_supplier_id(@supplier_id integer)
RETURNS national character varying(12)
AS

BEGIN
    RETURN
    (
	    SELECT inventory.suppliers.currency_code
	    FROM inventory.suppliers
	    WHERE inventory.suppliers.supplier_id = @supplier_id
	    AND inventory.suppliers.deleted = 0
    );
END



GO
