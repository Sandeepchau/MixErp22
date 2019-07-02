IF OBJECT_ID('inventory.is_parent_unit') IS NOT NULL
DROP FUNCTION inventory.is_parent_unit;

GO

CREATE FUNCTION inventory.is_parent_unit(@parent integer, @child integer)
RETURNS bit
AS      
BEGIN
    DECLARE @rows int;

    IF(@parent!=@child)
    BEGIN
        WITH unit_cte(unit_id) AS 
        (
            SELECT tn.compare_unit_id
            FROM inventory.compound_units AS tn 
            WHERE tn.base_unit_id = @parent
            AND tn.deleted = 0
            UNION ALL
            SELECT
            c.compare_unit_id
            FROM unit_cte AS p, 
            inventory.compound_units AS c 
            WHERE base_unit_id = p.unit_id
        )

        SELECT @rows = COUNT(*) from unit_cte
        WHERE unit_id=@child;

        IF(COALESCE(@rows, 0) > 0)
        BEGIN
            RETURN 1;
        END;
    END;
    RETURN 0;
END;

GO
