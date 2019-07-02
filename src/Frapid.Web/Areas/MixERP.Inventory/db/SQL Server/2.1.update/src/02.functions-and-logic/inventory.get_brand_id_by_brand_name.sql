IF OBJECT_ID('inventory.get_brand_id_by_brand_name') IS NOT NULL
DROP FUNCTION inventory.get_brand_id_by_brand_name;

GO

CREATE FUNCTION inventory.get_brand_id_by_brand_name(@brand_name national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT brand_id
	    FROM inventory.brands
	    WHERE inventory.brands.brand_name=@brand_name
	    AND inventory.brands.deleted = 0
    );
END;




GO
