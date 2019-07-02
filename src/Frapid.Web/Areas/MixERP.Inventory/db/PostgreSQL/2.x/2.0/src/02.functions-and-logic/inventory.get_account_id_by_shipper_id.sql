DROP FUNCTION IF EXISTS inventory.get_account_id_by_shipper_id(integer);

CREATE FUNCTION inventory.get_account_id_by_shipper_id(_shipper_id integer)
RETURNS integer
STABLE
AS
$$
BEGIN
    RETURN inventory.shippers.account_id
    FROM inventory.shippers
    WHERE inventory.shippers.shipper_id=_shipper_id
    AND NOT inventory.shippers.deleted;
END
$$
LANGUAGE plpgsql;

