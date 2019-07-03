IF OBJECT_ID('sales.get_item_selling_price') IS NOT NULL
DROP FUNCTION sales.get_item_selling_price;

GO

CREATE FUNCTION sales.get_item_selling_price(@office_id integer, @item_id integer, @customer_type_id integer, @price_type_id integer, @unit_id integer)
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @price              numeric(30, 6);
    DECLARE @costing_unit_id    integer;
    DECLARE @factor             numeric(30, 6);
    DECLARE @tax_rate           numeric(30, 6);
    DECLARE @includes_tax       bit;
    DECLARE @tax                numeric(30, 6);

    --Fist pick the catalog price which matches all these fields:
    --Item, Customer Type, Price Type, and Unit.
    --This is the most effective price.
    SELECT 
        @price              = item_selling_prices.price, 
        @costing_unit_id    = item_selling_prices.unit_id,
        @includes_tax       = item_selling_prices.includes_tax
    FROM sales.item_selling_prices
    WHERE item_selling_prices.item_id=@item_id
    AND item_selling_prices.customer_type_id=@customer_type_id
    AND item_selling_prices.price_type_id =@price_type_id
    AND item_selling_prices.unit_id = @unit_id
    AND sales.item_selling_prices.deleted = 0;

    IF(@costing_unit_id IS NULL)
    BEGIN
        --We do not have a selling price of this item for the unit supplied.
        --Let's see if this item has a price for other units.
        SELECT 
            @price              = item_selling_prices.price, 
            @costing_unit_id    = item_selling_prices.unit_id,
            @includes_tax       = item_selling_prices.includes_tax
        FROM sales.item_selling_prices
        WHERE item_selling_prices.item_id=@item_id
        AND item_selling_prices.customer_type_id=@customer_type_id
        AND item_selling_prices.price_type_id =@price_type_id
        AND sales.item_selling_prices.deleted = 0;
    END;

    IF(@price IS NULL)
    BEGIN
        SELECT 
            @price              = item_selling_prices.price, 
            @costing_unit_id    = item_selling_prices.unit_id,
            @includes_tax       = item_selling_prices.includes_tax
        FROM sales.item_selling_prices
        WHERE item_selling_prices.item_id=@item_id
        AND item_selling_prices.price_type_id =@price_type_id
        AND sales.item_selling_prices.deleted = 0;
    END;

    
    IF(@price IS NULL)
    BEGIN
        --This item does not have selling price defined in the catalog.
        --Therefore, getting the default selling price from the item definition.
        SELECT 
            @price              = selling_price, 
            @costing_unit_id    = unit_id,
            @includes_tax       = 0
        FROM inventory.items
        WHERE inventory.items.item_id = @item_id
        AND inventory.items.deleted = 0;
    END;

    IF(@includes_tax = 1)
    BEGIN
        SET @tax_rate = finance.get_sales_tax_rate(@office_id);
        SET @price = @price / ((100 + @tax_rate)/ 100);
    END;

    --Get the unitary conversion factor if the requested unit does not match with the price defition.
    SET @factor = inventory.convert_unit(@unit_id, @costing_unit_id);

    RETURN @price * @factor;
END;

GO

