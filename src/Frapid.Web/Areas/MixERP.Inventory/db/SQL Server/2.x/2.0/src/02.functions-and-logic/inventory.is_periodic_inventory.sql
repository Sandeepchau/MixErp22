IF OBJECT_ID('inventory.is_periodic_inventory') IS NOT NULL
DROP FUNCTION inventory.is_periodic_inventory;

GO

CREATE FUNCTION inventory.is_periodic_inventory(@office_id integer)
RETURNS bit
AS
BEGIN
    IF EXISTS(SELECT * FROM inventory.inventory_setup WHERE inventory_system = 'Periodic' AND office_id = @office_id)
    BEGIN
        RETURN 1;
    END;

    RETURN 0;
END;

GO

ALTER FUNCTION finance.is_periodic_inventory(@office_id integer)
RETURNS bit
AS
BEGIN
    RETURN inventory.is_periodic_inventory(@office_id);
END;

GO
