DROP FUNCTION IF EXISTS inventory.items_unit_check_trigger() CASCADE;

CREATE FUNCTION inventory.items_unit_check_trigger()
RETURNS TRIGGER
AS
$$        
BEGIN
    IF(inventory.get_root_unit_id(NEW.unit_id) != inventory.get_root_unit_id(NEW.reorder_unit_id)) THEN
        RAISE EXCEPTION 'The reorder unit is incompatible with the base unit.'
        USING ERRCODE='P3054';
    END IF;
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER items_unit_check_trigger
AFTER INSERT OR UPDATE
ON inventory.items
FOR EACH ROW EXECUTE PROCEDURE inventory.items_unit_check_trigger();