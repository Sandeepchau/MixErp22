IF OBJECT_ID('inventory.get_cost_of_good_method') IS NOT NULL
DROP FUNCTION inventory.get_cost_of_good_method;

GO

CREATE FUNCTION inventory.get_cost_of_good_method(@office_id integer)
RETURNS national character varying(500)
AS
BEGIN
    RETURN
    (
	    SELECT inventory.inventory_setup.cogs_calculation_method
	    FROM inventory.inventory_setup
	    WHERE inventory.inventory_setup.office_id=@office_id
    );
END;

GO

--SELECT * FROM inventory.get_cost_of_good_method(1);
