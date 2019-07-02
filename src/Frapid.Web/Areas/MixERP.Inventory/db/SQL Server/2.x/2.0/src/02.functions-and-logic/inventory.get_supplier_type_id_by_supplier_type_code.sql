IF OBJECT_ID('inventory.get_supplier_type_id_by_supplier_type_code') IS NOT NULL
DROP FUNCTION inventory.get_supplier_type_id_by_supplier_type_code;

GO

CREATE FUNCTION inventory.get_supplier_type_id_by_supplier_type_code(@supplier_type_code national character varying(24))
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT supplier_type_id
	    FROM inventory.supplier_types
	    WHERE inventory.supplier_types.supplier_type_code=@supplier_type_code
	    AND inventory.supplier_types.deleted = 0
    );
END;




GO
