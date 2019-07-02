DROP FUNCTION IF EXISTS inventory.get_item_name_by_item_id(item_id_ int);

CREATE OR REPLACE FUNCTION inventory.get_item_name_by_item_id(item_id_ int)
RETURNS national character varying(50) 
AS
$$
BEGIN
    RETURN item_name
    FROM inventory.items
    WHERE inventory.items.item_id = item_id_
	AND NOT inventory.items.deleted;
END
$$
  LANGUAGE plpgsql;