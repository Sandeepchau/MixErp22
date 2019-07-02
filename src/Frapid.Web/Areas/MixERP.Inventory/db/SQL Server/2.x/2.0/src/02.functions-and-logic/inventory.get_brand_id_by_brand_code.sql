IF OBJECT_ID('inventory.get_brand_id_by_brand_code') IS NOT NULL
DROP FUNCTION inventory.get_brand_id_by_brand_code;

GO

CREATE FUNCTION inventory.get_brand_id_by_brand_code(@brand_code national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT brand_id
	    FROM inventory.brands
	    WHERE inventory.brands.brand_code=@brand_code
	    AND inventory.brands.deleted = 0
    );
END;




GO
