IF OBJECT_ID('inventory.get_shipper_id_by_shipper_code') IS NOT NULL
DROP FUNCTION inventory.get_shipper_id_by_shipper_code;

GO

CREATE FUNCTION inventory.get_shipper_id_by_shipper_code(@shipper_code national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT inventory.shippers.shipper_id
	    FROM inventory.shippers
	    WHERE inventory.shippers.shipper_code = @shipper_code
    );
END



GO
