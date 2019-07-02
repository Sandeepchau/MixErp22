DROP FUNCTION IF EXISTS inventory.create_item_variant
(
    _variant_of             integer,
    _item_id                integer,
    _item_code              national character varying(12),
    _item_name              national character varying(100),
    _variants               text,
    _user_id                integer
);

CREATE FUNCTION inventory.create_item_variant
(
    _variant_of             integer,
    _item_id                integer,
    _item_code              national character varying(12),
    _item_name              national character varying(100),
    _variants               text,
    _user_id                integer
)
RETURNS integer
AS
$$
   DECLARE _variant_ids     integer[] = _variants::integer[];
BEGIN

    IF(COALESCE(_item_id, 0) = 0) THEN
        INSERT INTO inventory.items
        (
            item_code, 
            item_name, 
            item_group_id, 
            item_type_id, 
            brand_id, 
            preferred_supplier_id, 
            lead_time_in_days, 
            unit_id,
            hot_item,
            cost_price,
            selling_price,
            selling_price_includes_tax,
            reorder_unit_id,
            reorder_level,
            reorder_quantity,
            maintain_inventory,
            audit_user_id,
            photo,
            is_variant_of
        )
        SELECT
                _item_code, 
                _item_name, 
                item_group_id, 
                item_type_id, 
                brand_id, 
                preferred_supplier_id, 
                lead_time_in_days, 
                unit_id,
                hot_item,
                cost_price,
                selling_price,
                selling_price_includes_tax,
                reorder_unit_id,
                reorder_level,
                reorder_quantity,
                maintain_inventory,
                _user_id,
                photo,
                _variant_of
        FROM inventory.items
        WHERE item_id = _variant_of
        RETURNING item_id
        INTO _item_id;
    END IF;

    DELETE FROM inventory.item_variants
    WHERE item_id = _item_id
    AND variant_id NOT IN
    (
        SELECT explode_array(_variant_ids)
    );

    WITH variants
    AS
    (
        SELECT explode_array(_variant_ids) AS variant_id
    ),
    new
    AS
    (
        SELECT variant_id FROM variants WHERE
        variant_id NOT IN
        (
            SELECT inventory.item_variants.variant_id
            FROM inventory.item_variants
            WHERE item_id = _item_id
        )
    )
    
    INSERT INTO inventory.item_variants(item_id, variant_id, audit_user_id)
    SELECT _item_id, variant_id, _user_id
    FROM new;
    

    RETURN _item_id;
END
$$
LANGUAGE plpgsql;


