IF OBJECT_ID('inventory.get_office_id_by_counter_id') IS NOT NULL
DROP FUNCTION inventory.get_office_id_by_counter_id;

GO

CREATE FUNCTION inventory.get_office_id_by_counter_id(@counter_id integer)
RETURNS integer
AS
BEGIN
    RETURN 
	(
		SELECT inventory.stores.office_id
		FROM inventory.stores
		INNER JOIN inventory.counters
		ON inventory.counters.store_id = inventory.stores.store_id
		AND inventory.counters.counter_id = @counter_id
		AND inventory.counters.deleted = 0
	);
END

GO


--SELECT inventory.get_office_id_by_counter_id(1);
