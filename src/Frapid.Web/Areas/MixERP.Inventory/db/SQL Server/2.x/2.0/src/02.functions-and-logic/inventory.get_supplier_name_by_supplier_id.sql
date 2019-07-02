IF OBJECT_ID('inventory.get_supplier_name_by_supplier_id') IS NOT NULL
DROP FUNCTION inventory.get_supplier_name_by_supplier_id;

GO

CREATE FUNCTION inventory.get_supplier_name_by_supplier_id(@supplier_id integer)
RETURNS national character varying(500)
AS

BEGIN
    RETURN
    (
	    SELECT inventory.suppliers.supplier_name
	    FROM inventory.suppliers
	    WHERE inventory.suppliers.supplier_id = @supplier_id
    );
END;




GO
