IF OBJECT_ID('inventory.get_customer_id_by_customer_code') IS NOT NULL
DROP FUNCTION inventory.get_customer_id_by_customer_code;

GO

CREATE FUNCTION inventory.get_customer_id_by_customer_code(@customer_code national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT customer_id
	    FROM inventory.customers
	    WHERE inventory.customers.customer_code=@customer_code
	    AND inventory.customers.deleted = 0
    );
END;




GO
