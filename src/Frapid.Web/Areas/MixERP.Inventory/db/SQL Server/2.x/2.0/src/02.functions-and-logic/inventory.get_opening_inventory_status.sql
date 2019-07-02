
-->-->-- src/Frapid.Web/Areas/MixERP.Inventory/db/SQL Server/2.x/2.0/src/02.functions-and-logic/inventory.get_opening_inventory_status.sql --<--<--
IF OBJECT_ID('inventory.get_opening_inventory_status') IS NOT NULL
DROP FUNCTION inventory.get_opening_inventory_status;

GO

CREATE FUNCTION inventory.get_opening_inventory_status
(
    @office_id                                      integer
)
RETURNS @result TABLE
(
    office_id                                       integer,
    multiple_inventory_allowed                      bit,
    has_opening_inventory                           bit
)
AS
BEGIN
    DECLARE @multiple_inventory_allowed             bit;
    DECLARE @has_opening_inventory                  bit = 0;

    SELECT @multiple_inventory_allowed = inventory.inventory_setup.allow_multiple_opening_inventory 
    FROM inventory.inventory_setup
    WHERE inventory.inventory_setup.office_id = @office_id;

    IF EXISTS
    (
        SELECT 1
        FROM finance.transaction_master
        WHERE finance.transaction_master.book = 'Opening Inventory'
        AND finance.transaction_master.office_id = @office_id
    )
    BEGIN
        SET @has_opening_inventory                      = 1;
    END;
    
    INSERT INTO @result
    SELECT @office_id, @multiple_inventory_allowed, @has_opening_inventory;

    RETURN;
END;



--SELECT * FROM inventory.get_opening_inventory_status(1);

GO
