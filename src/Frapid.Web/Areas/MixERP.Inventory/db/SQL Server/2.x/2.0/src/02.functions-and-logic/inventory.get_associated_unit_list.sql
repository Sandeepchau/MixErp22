IF OBJECT_ID('inventory.get_associated_unit_list') IS NOT NULL
DROP FUNCTION inventory.get_associated_unit_list;

GO

CREATE FUNCTION inventory.get_associated_unit_list(@any_unit_id integer)
RETURNS @result TABLE
(
    unit_id             integer
)
AS
BEGIN
    DECLARE @root_unit_id integer = inventory.get_root_unit_id(@any_unit_id);
        
    INSERT INTO @result(unit_id) 
    SELECT @root_unit_id
    WHERE NOT EXISTS
    (
        SELECT * FROM @result
        WHERE unit_id=@root_unit_id
    );
    
    WITH cte(unit_id)
    AS
    (
         SELECT 
            compare_unit_id
         FROM 
            inventory.compound_units
         WHERE 
            base_unit_id = @root_unit_id

        UNION ALL

         SELECT
            units.compare_unit_id
         FROM 
            inventory.compound_units units
         INNER JOIN cte 
         ON cte.unit_id = units.base_unit_id
    )
    
    INSERT INTO @result(unit_id)
    SELECT cte.unit_id FROM cte;
    
    DELETE FROM @result
    WHERE unit_id IS NULL;
    
    RETURN;
END;



--SELECT * FROM inventory.get_associated_unit_list(1);

GO
