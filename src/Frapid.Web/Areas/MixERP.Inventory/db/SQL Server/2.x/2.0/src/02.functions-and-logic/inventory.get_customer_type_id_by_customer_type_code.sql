IF OBJECT_ID('inventory.get_customer_type_id_by_customer_type_code') IS NOT NULL
DROP FUNCTION inventory.get_customer_type_id_by_customer_type_code;

GO

CREATE FUNCTION inventory.get_customer_type_id_by_customer_type_code(@customer_type_code national character varying(24))
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT customer_type_id
	    FROM inventory.customer_types
	    WHERE inventory.customer_types.customer_type_code=@customer_type_code
	    AND inventory.customer_types.deleted = 0
    );
END;




GO
