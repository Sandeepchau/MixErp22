IF OBJECT_ID('inventory.get_mavcogs') IS NOT NULL
DROP FUNCTION inventory.get_mavcogs;

GO

CREATE FUNCTION inventory.get_mavcogs(@item_id integer, @store_id integer, @base_quantity numeric(30, 6), @factor numeric(30, 6))
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @base_unit_cost numeric(30, 6);

    DECLARE @temp_staging TABLE
    (
        id              integer IDENTITY NOT NULL,
        value_date      date,
        audit_ts        DATETIMEOFFSET,
        base_quantity   numeric(30, 6),
        price           numeric(30, 6)
    ) ;


    INSERT INTO @temp_staging(value_date, audit_ts, base_quantity, price)
    SELECT value_date, audit_ts, 
    CASE WHEN transaction_type = 'Dr' THEN
    base_quantity ELSE base_quantity  * -1 END, 
    CASE WHEN transaction_type = 'Dr' THEN
    (price * quantity/base_quantity)
    ELSE
    0
    END
    FROM inventory.verified_checkout_details_view
    WHERE item_id = @item_id
    AND store_id=@store_id
    order by value_date, audit_ts, checkout_detail_id;




    WITH stock_transaction(id, base_quantity, price, sum_m, sum_base_quantity, last_id) AS 
    (
      SELECT id, base_quantity, price, base_quantity * price, base_quantity, id
      FROM @temp_staging WHERE id = 1
      UNION ALL
      SELECT child.id, child.base_quantity, 
             CAST(CASE WHEN child.base_quantity < 0 then parent.sum_m / parent.sum_base_quantity ELSE child.price END AS numeric(30, 6)), 
             parent.sum_m + CASE WHEN child.base_quantity < 0 then parent.sum_m / parent.sum_base_quantity ELSE child.price END * child.base_quantity,
             CAST(parent.sum_base_quantity + child.base_quantity AS numeric(30, 6)),
             child.id 
      FROM @temp_staging child JOIN stock_transaction parent on child.id = parent.last_id + 1
    )

    SELECT
    TOP 1
            --base_quantity,                                                        --left for debuging purpose
            --price,                                                                --left for debuging purpose
            --base_quantity * price AS amount,                                      --left for debuging purpose
            --SUM(base_quantity * price) OVER(ORDER BY id) AS cv_amount,            --left for debuging purpose
            --SUM(base_quantity) OVER(ORDER BY id) AS cv_quantity,                  --left for debuging purpose
            @base_unit_cost = SUM(base_quantity * price) OVER(ORDER BY id)  / SUM(base_quantity) OVER(ORDER BY id)
    FROM stock_transaction
    ORDER BY id DESC;

    RETURN @base_unit_cost * @factor * @base_quantity;
END;






GO


