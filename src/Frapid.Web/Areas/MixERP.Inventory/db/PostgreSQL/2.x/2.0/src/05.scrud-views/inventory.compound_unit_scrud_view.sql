DROP VIEW IF EXISTS inventory.compound_unit_scrud_view;

CREATE VIEW inventory.compound_unit_scrud_view
AS
SELECT
    compound_unit_id,
    base_unit.unit_name base_unit_name,
    value,
    compare_unit.unit_name compare_unit_name
FROM
    inventory.compound_units,
    inventory.units base_unit,
    inventory.units compare_unit
WHERE inventory.compound_units.base_unit_id = base_unit.unit_id
AND inventory.compound_units.compare_unit_id = compare_unit.unit_id;
