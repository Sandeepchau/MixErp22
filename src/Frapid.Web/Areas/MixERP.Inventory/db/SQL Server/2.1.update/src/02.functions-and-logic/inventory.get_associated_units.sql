IF OBJECT_ID('inventory.get_associated_unit_csv_list') IS NOT NULL
DROP FUNCTION inventory.get_associated_unit_csv_list;

GO

CREATE FUNCTION inventory.get_associated_unit_csv_list(@any_unit_id integer)
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
    
    INSERT INTO @result(unit_id)
    SELECT cte.unit_id FROM cte;
    
    DELETE FROM @result
    WHERE unit_id IS NULL;
    
    RETURN;
END;



GO


--SELECT * FROM inventory.get_associated_unit_list(24);


IF OBJECT_ID('inventory.get_associated_unit_list_csv') IS NOT NULL
DROP FUNCTION inventory.get_associated_unit_list_csv;

GO

CREATE FUNCTION inventory.get_associated_unit_list_csv(@any_unit_id integer)
RETURNS varchar(MAX)
AS
BEGIN
    DECLARE @result TABLE
    (
        unit_id integer, 
        unit_code national character varying(24), 
        unit_name national character varying(500)
    );

    DECLARE @csv varchar(MAX);
    INSERT INTO @result(unit_id)
    SELECT * FROM inventory.get_associated_unit_list(@any_unit_id);

    SELECT @csv = COALESCE(@csv + ',', '') +  CONVERT(varchar, unit_id)
    FROM @result
    ORDER BY unit_id;
        
    RETURN @csv;
END;



GO


--SELECT inventory.get_associated_unit_list_csv(24);


