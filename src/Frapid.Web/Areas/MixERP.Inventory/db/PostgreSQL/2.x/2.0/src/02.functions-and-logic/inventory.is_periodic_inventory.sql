DROP FUNCTION IF EXISTS inventory.is_periodic_inventory(_office_id integer);

CREATE FUNCTION inventory.is_periodic_inventory(_office_id integer)
RETURNS boolean
AS
$$
BEGIN
    IF EXISTS(SELECT * FROM inventory.inventory_setup WHERE inventory_system = 'Periodic' AND office_id = _office_id) THEN
        RETURN true;
    END IF;

    RETURN false;
END
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION finance.is_periodic_inventory(_office_id integer)
RETURNS boolean
AS
$$
BEGIN
    RETURN inventory.is_periodic_inventory(_office_id);
END
$$
LANGUAGE plpgsql;

