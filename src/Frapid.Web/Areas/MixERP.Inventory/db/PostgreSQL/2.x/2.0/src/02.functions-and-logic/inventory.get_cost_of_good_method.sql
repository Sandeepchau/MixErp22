DROP FUNCTION IF EXISTS inventory.get_cost_of_good_method(_office_id integer);

CREATE FUNCTION inventory.get_cost_of_good_method(_office_id integer)
RETURNS text
AS
$$
BEGIN
    RETURN inventory.inventory_setup.cogs_calculation_method
    FROM inventory.inventory_setup
    WHERE inventory.inventory_setup.office_id=$1;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM inventory.get_cost_of_good_method(1);