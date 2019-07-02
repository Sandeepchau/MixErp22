DROP FUNCTION IF EXISTS inventory.get_associated_units(_any_unit_id integer);

CREATE FUNCTION inventory.get_associated_units(_any_unit_id integer)
RETURNS TABLE
(
    unit_id integer, 
    unit_code text, 
    unit_name text
)
VOLATILE
AS
$$
    DECLARE root_unit_id integer;
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_unit(unit_id integer) ON COMMIT DROP; 
    
    SELECT inventory.get_root_unit_id(_any_unit_id) INTO root_unit_id;
    
    INSERT INTO temp_unit(unit_id) 
    SELECT root_unit_id
    WHERE NOT EXISTS
    (
        SELECT * FROM temp_unit
        WHERE temp_unit.unit_id=root_unit_id
    );
    
    WITH RECURSIVE cte(unit_id)
    AS
    (
         SELECT 
            compare_unit_id
         FROM 
            inventory.compound_units
         WHERE 
            base_unit_id = root_unit_id
		 AND deleted = 0
		 
        UNION ALL

         SELECT
            units.compare_unit_id
         FROM 
            inventory.compound_units units
         INNER JOIN cte 
         ON cte.unit_id = units.base_unit_id
		 WHERE deleted = 0
    )
    
    INSERT INTO temp_unit(unit_id)
    SELECT cte.unit_id FROM cte;
    
    DELETE FROM temp_unit
    WHERE temp_unit.unit_id IS NULL;
    
    RETURN QUERY 
    SELECT 
        inventory.units.unit_id,
        inventory.units.unit_code::text,
        inventory.units.unit_name::text
    FROM
        inventory.units
    WHERE
        inventory.units.unit_id 
    IN
    (
        SELECT temp_unit.unit_id FROM temp_unit
    );
END
$$
LANGUAGE plpgsql;