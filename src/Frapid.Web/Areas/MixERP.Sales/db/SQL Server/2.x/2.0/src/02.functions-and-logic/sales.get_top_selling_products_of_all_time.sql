IF OBJECT_ID('sales.get_top_selling_products_of_all_time') IS NOT NULL
DROP FUNCTION sales.get_top_selling_products_of_all_time;

GO

CREATE FUNCTION sales.get_top_selling_products_of_all_time(@office_id int)
RETURNS @result TABLE
(
    id              integer,
    item_id         integer,
    item_code       text,
    item_name       text,
    total_sales     numeric(30, 6)
)
AS
BEGIN
    INSERT INTO @result(id, item_id, total_sales)
    SELECT ROW_NUMBER() OVER(ORDER BY sales_amount DESC), *
    FROM
    (
        SELECT
        TOP 10      
                inventory.verified_checkout_view.item_id, 
                SUM((price * quantity) - COALESCE(discount, 0) + COALESCE(shipping_charge, 0)) AS sales_amount
        FROM inventory.verified_checkout_view
        WHERE inventory.verified_checkout_view.office_id = @office_id
        AND inventory.verified_checkout_view.book LIKE 'Sales%'
        GROUP BY inventory.verified_checkout_view.item_id
        ORDER BY 2 DESC
    ) t;

    UPDATE result
    SET 
        item_code = inventory.items.item_code,
        item_name = inventory.items.item_name
    FROM @result AS result
    INNER JOIN inventory.items
    ON result.item_id = inventory.items.item_id;
    
    RETURN;
END

GO

--SELECT * FROM sales.get_top_selling_products_of_all_time(1);

