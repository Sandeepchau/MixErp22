DROP FUNCTION IF EXISTS inventory.get_office_id_by_counter_id(_counter_id integer);

CREATE FUNCTION inventory.get_office_id_by_counter_id(_counter_id integer)
RETURNS integer
AS
$$
BEGIN
    RETURN inventory.stores.office_id
    FROM inventory.stores
    INNER JOIN inventory.counters
    ON inventory.counters.store_id = inventory.stores.store_id
    AND inventory.counters.counter_id = _counter_id
    AND NOT inventory.counters.deleted;
END
$$
LANGUAGE plpgsql;


--SELECT inventory.get_office_id_by_counter_id(1);