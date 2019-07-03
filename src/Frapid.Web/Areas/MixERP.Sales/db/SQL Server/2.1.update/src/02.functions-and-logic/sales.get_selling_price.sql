IF OBJECT_ID('sales.get_selling_price') IS NOT NULL
DROP FUNCTION sales.get_selling_price;

GO

CREATE FUNCTION sales.get_selling_price(@office_id integer, @item_id integer, @customer_id integer, @price_type_id integer, @unit_id integer)
RETURNS numeric(30, 6)
AS
BEGIN	
    DECLARE @price              decimal(30, 6);
    DECLARE @costing_unit_id    integer;
    DECLARE @factor             decimal(30, 6);
    DECLARE @tax_rate           decimal(30, 6);
    DECLARE @includes_tax       bit;
    DECLARE @tax                decimal(30, 6);
	DECLARE @customer_type_id	integer;

	SELECT
		@includes_tax	= inventory.items.selling_price_includes_tax
	FROM inventory.items
	WHERE inventory.items.item_id = @item_id;
	
	SELECT
		@price				= sales.customerwise_selling_prices.price,
		@costing_unit_id	= sales.customerwise_selling_prices.unit_id,
		@includes_tax		= sales.customerwise_selling_prices.is_taxable
	FROM sales.customerwise_selling_prices
	WHERE sales.customerwise_selling_prices.deleted = 0
	AND sales.customerwise_selling_prices.customer_id = @customer_id
	AND sales.customerwise_selling_prices.item_id = @item_id;

	IF(COALESCE(@price, 0) = 0)
	BEGIN
		RETURN sales.get_item_selling_price(@office_id, @item_id, inventory.get_customer_type_id_by_customer_id(@customer_id), @price_type_id, @unit_id);
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

--SELECT sales.get_selling_price(1,1,1,1,6);
