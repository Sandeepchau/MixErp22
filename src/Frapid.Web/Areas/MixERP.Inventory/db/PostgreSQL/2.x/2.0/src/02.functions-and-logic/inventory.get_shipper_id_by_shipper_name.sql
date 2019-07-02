DROP FUNCTION IF EXISTS inventory.get_shipper_id_by_shipper_name(_shipper_name national character varying(24));

CREATE FUNCTION inventory.get_shipper_id_by_shipper_name(_shipper_name national character varying(24))
RETURNS integer
AS
$$
BEGIN
    RETURN inventory.shippers.shipper_id
    FROM inventory.shippers
    WHERE inventory.shippers.shipper_name = _shipper_name;
END
$$
LANGUAGE plpgsql;