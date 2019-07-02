IF OBJECT_ID('inventory.convert_unit') IS NOT NULL
DROP FUNCTION inventory.convert_unit;

GO

CREATE FUNCTION inventory.convert_unit(@from_unit integer, @to_unit integer)
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @factor numeric(30, 6);

    IF(inventory.get_root_unit_id(@from_unit) != inventory.get_root_unit_id(@to_unit))
    BEGIN
        RETURN 0;
    END;

    IF(@from_unit = @to_unit)
    BEGIN
        RETURN 1.00;
    END;
    
    IF(inventory.is_parent_unit(@from_unit, @to_unit) = 1)
    BEGIN
            WITH unit_cte(unit_id, value) AS 
            (
                SELECT tn.compare_unit_id, tn.value
                FROM inventory.compound_units AS tn 
                WHERE tn.base_unit_id = @from_unit
                AND tn.deleted = 0

                UNION ALL

                SELECT 
                c.compare_unit_id, c.value * p.value
                FROM unit_cte AS p, 
                inventory.compound_units AS c 
                WHERE base_unit_id = p.unit_id
            )
        SELECT @factor = 1.00/value
        FROM unit_cte
        WHERE unit_id=@to_unit;
    END
    ELSE
    BEGIN
            WITH unit_cte(unit_id, value) AS 
            (
             SELECT tn.compare_unit_id, tn.value
                FROM inventory.compound_units AS tn 
                WHERE tn.base_unit_id = @to_unit
                AND tn.deleted = 0
            UNION ALL
             SELECT 
                c.compare_unit_id, c.value * p.value
                FROM unit_cte AS p, 
              inventory.compound_units AS c 
                WHERE base_unit_id = p.unit_id
            )

        SELECT @factor = value
        FROM unit_cte
        WHERE unit_id=@from_unit;
    END;

    RETURN @factor;
END;






GO
