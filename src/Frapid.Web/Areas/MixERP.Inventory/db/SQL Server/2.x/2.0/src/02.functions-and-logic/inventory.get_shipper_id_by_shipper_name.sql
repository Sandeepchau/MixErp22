IF OBJECT_ID('inventory.get_shipper_id_by_shipper_name') IS NOT NULL
DROP FUNCTION inventory.get_shipper_id_by_shipper_name;

GO

CREATE FUNCTION inventory.get_shipper_id_by_shipper_name(@shipper_name national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT inventory.shippers.shipper_id
	    FROM inventory.shippers
	    WHERE inventory.shippers.shipper_name = @shipper_name
    );
END



GO
