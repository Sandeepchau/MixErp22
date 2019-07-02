DROP FUNCTION IF EXISTS inventory.list_closing_stock
(
    _store_id               integer
);

CREATE FUNCTION inventory.list_closing_stock
(
    _store_id               integer
)
RETURNS TABLE
(
    item_id                 integer,
    item_code				national character varying(50),
    item_name               national character varying(1000),
    unit_id                 integer,
    unit_name               national character varying(1000),
    quantity                numeric(30, 6)
)
AS
$$
BEGIN
    DROP TABLE IF EXISTS temp_closing_stock;
    CREATE TEMPORARY TABLE temp_closing_stock
    (
        item_id             integer,
        item_code			national character varying(50),
        item_name           national character varying(1000),
        base_unit_id        integer,
		unit_id				integer,
        unit_name           national character varying(1000),
        base_quantity       numeric(30, 6),
        quantity			numeric(30, 6),
		unit_conversion		numeric(30, 6),
        maintain_inventory  boolean
    ) ON COMMIT DROP;

    INSERT INTO temp_closing_stock(item_id, base_unit_id, base_quantity)
    SELECT 
        inventory.verified_checkout_details_view.item_id, 
        inventory.verified_checkout_details_view.base_unit_id,
        SUM(CASE WHEN inventory.verified_checkout_details_view.transaction_type='Dr' THEN inventory.verified_checkout_details_view.base_quantity ELSE inventory.verified_checkout_details_view.base_quantity * -1 END)
    FROM inventory.verified_checkout_details_view
    WHERE inventory.verified_checkout_details_view.store_id = _store_id
    GROUP BY inventory.verified_checkout_details_view.item_id, inventory.verified_checkout_details_view.store_id, inventory.verified_checkout_details_view.base_unit_id;

    UPDATE temp_closing_stock 
    SET 
        item_code = inventory.items.item_code,
        item_name = inventory.items.item_name,
        maintain_inventory = inventory.items.maintain_inventory
    FROM inventory.items
    WHERE temp_closing_stock.item_id = inventory.items.item_id;

    DELETE FROM temp_closing_stock WHERE NOT maintain_inventory;

	UPDATE temp_closing_stock
	SET unit_id = inventory.items.unit_id
	FROM inventory.items
	WHERE inventory.items.item_id = temp_closing_stock.item_id;

    UPDATE temp_closing_stock 
    SET 
        unit_name = inventory.units.unit_name,
		unit_conversion = inventory.convert_unit(temp_closing_stock.base_unit_id, temp_closing_stock.unit_id) 
    FROM inventory.units
    WHERE temp_closing_stock.unit_id = inventory.units.unit_id;

	UPDATE temp_closing_stock
	SET quantity = base_quantity * unit_conversion;

    RETURN QUERY
    SELECT 
        temp_closing_stock.item_id, 
        temp_closing_stock.item_code, 
        temp_closing_stock.item_name, 
        temp_closing_stock.unit_id, 
        temp_closing_stock.unit_name, 
        temp_closing_stock.quantity
    FROM temp_closing_stock
    ORDER BY temp_closing_stock.item_id;
END
$$
LANGUAGE plpgsql;



--SELECT * FROM inventory.list_closing_stock(1);

