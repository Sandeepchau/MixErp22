DROP FUNCTION IF EXISTS inventory.get_item_code_by_item_id(integer);
CREATE OR REPLACE FUNCTION inventory.get_item_code_by_item_id(item_id_ integer)
RETURNS national character varying(24) 
AS
$$
BEGIN
    RETURN item_code
    FROM inventory.items
    WHERE inventory.items.item_id = item_id_
    AND NOT inventory.items.deleted;
END
$$
LANGUAGE plpgsql;