DROP FUNCTION IF EXISTS inventory.get_brand_id_by_brand_code(text);

CREATE FUNCTION inventory.get_brand_id_by_brand_code(text)
RETURNS integer
AS
$$
BEGIN
        RETURN brand_id
        FROM inventory.brands
        WHERE inventory.brands.brand_code=$1
		AND NOT inventory.brands.deleted;
END
$$
LANGUAGE plpgsql;
