DROP FUNCTION IF EXISTS sales.get_top_selling_products_of_all_time(_office_id int);

CREATE FUNCTION sales.get_top_selling_products_of_all_time(_office_id int)
RETURNS TABLE
(
    id              integer,
    item_id         integer,
    item_code       text,
    item_name       text,
    total_sales     numeric
)
AS
$$
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS top_selling_products_of_all_time
    (
        id              integer,
        item_id         integer,
        item_code       text,
        item_name       text,
        total_sales     numeric
    ) ON COMMIT DROP;

    INSERT INTO top_selling_products_of_all_time(id, item_id, total_sales)
    SELECT ROW_NUMBER() OVER(), *
    FROM
    (
        SELECT         
                inventory.verified_checkout_view.item_id, 
                SUM((price * quantity) - COALESCE(discount, 0) + COALESCE(shipping_charge)) AS sales_amount
        FROM inventory.verified_checkout_view
        WHERE inventory.verified_checkout_view.office_id = _office_id
        AND inventory.verified_checkout_view.book ILIKE 'sales%'
        GROUP BY inventory.verified_checkout_view.item_id
        ORDER BY 2 DESC
        LIMIT 10
    ) t;

    UPDATE top_selling_products_of_all_time AS t
    SET 
        item_code = inventory.items.item_code,
        item_name = inventory.items.item_name
    FROM inventory.items
    WHERE t.item_id = inventory.items.item_id;
    
    RETURN QUERY
    SELECT * FROM top_selling_products_of_all_time;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM sales.get_top_selling_products_of_all_time(1);