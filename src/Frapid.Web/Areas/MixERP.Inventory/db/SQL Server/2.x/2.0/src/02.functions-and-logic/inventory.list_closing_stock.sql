IF OBJECT_ID('inventory.list_closing_stock') IS NOT NULL
DROP FUNCTION inventory.list_closing_stock;

GO

CREATE FUNCTION inventory.list_closing_stock
(
    @store_id               integer
)
RETURNS @result TABLE
(
    item_id                 integer,
    item_code				national character varying(50),
    item_name               national character varying(1000),
    unit_id                 integer,
    unit_name               national character varying(1000),
    quantity                numeric(30, 6)
)
AS

BEGIN
    DECLARE @temp_closing_stock TABLE
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
        maintain_inventory  bit
    ) ;

    INSERT INTO @temp_closing_stock(item_id, base_unit_id, base_quantity)
    SELECT 
        inventory.verified_checkout_details_view.item_id, 
        inventory.verified_checkout_details_view.base_unit_id,
        SUM(CASE WHEN inventory.verified_checkout_details_view.transaction_type='Dr' THEN inventory.verified_checkout_details_view.base_quantity ELSE inventory.verified_checkout_details_view.base_quantity * -1 END)
    FROM inventory.verified_checkout_details_view
    WHERE inventory.verified_checkout_details_view.store_id = @store_id
    GROUP BY inventory.verified_checkout_details_view.item_id, inventory.verified_checkout_details_view.store_id, inventory.verified_checkout_details_view.base_unit_id;

    UPDATE @temp_closing_stock 
    SET 
        item_code = inventory.items.item_code,
        item_name = inventory.items.item_name,
        maintain_inventory = inventory.items.maintain_inventory
    FROM @temp_closing_stock AS temp_closing_stock
    INNER JOIN inventory.items
    ON temp_closing_stock.item_id = inventory.items.item_id;

    DELETE FROM @temp_closing_stock WHERE maintain_inventory = 0;

	UPDATE @temp_closing_stock
	SET unit_id = inventory.items.unit_id
	FROM @temp_closing_stock AS temp_closing_stock 
	INNER JOIN inventory.items
	ON inventory.items.item_id = temp_closing_stock.item_id;

    UPDATE @temp_closing_stock 
    SET 
        unit_name = inventory.units.unit_name,
		unit_conversion = inventory.convert_unit(temp_closing_stock.base_unit_id, temp_closing_stock.unit_id) 
    FROM @temp_closing_stock AS temp_closing_stock
    INNER JOIN inventory.units
    ON temp_closing_stock.unit_id = inventory.units.unit_id;

	UPDATE @temp_closing_stock
	SET quantity = base_quantity * unit_conversion;

    INSERT INTO @result
    SELECT 
        temp_closing_stock.item_id, 
        temp_closing_stock.item_code, 
        temp_closing_stock.item_name, 
        temp_closing_stock.unit_id, 
        temp_closing_stock.unit_name, 
        temp_closing_stock.quantity
    FROM @temp_closing_stock AS temp_closing_stock
    ORDER BY temp_closing_stock.item_id;

    RETURN;
END;


GO


--SELECT * FROM inventory.list_closing_stock(1)

