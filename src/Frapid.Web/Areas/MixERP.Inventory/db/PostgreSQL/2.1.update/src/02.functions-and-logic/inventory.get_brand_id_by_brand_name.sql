DROP FUNCTION IF EXISTS inventory.get_brand_id_by_brand_name(text);

CREATE FUNCTION inventory.get_brand_id_by_brand_name(text)
RETURNS integer
AS
$$
BEGIN
        RETURN brand_id
        FROM inventory.brands
        WHERE inventory.brands.brand_name=$1
		AND NOT inventory.brands.deleted;
END
$$
LANGUAGE plpgsql;
