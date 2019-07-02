IF OBJECT_ID('inventory.get_supplier_id_by_supplier_code') IS NOT NULL
DROP FUNCTION inventory.get_supplier_id_by_supplier_code;

GO

CREATE FUNCTION inventory.get_supplier_id_by_supplier_code(@supplier_code national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT supplier_id
	    FROM inventory.suppliers
	    WHERE inventory.suppliers.supplier_code=@supplier_code
	    AND inventory.suppliers.deleted = 0
    );
END;




GO
