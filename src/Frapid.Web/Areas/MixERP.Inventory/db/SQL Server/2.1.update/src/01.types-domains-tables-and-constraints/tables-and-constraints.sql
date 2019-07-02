IF COL_LENGTH('inventory.inventory_setup', 'validate_returns') IS NULL
BEGIN
    ALTER TABLE inventory.inventory_setup
    ADD validate_returns bit NOT NULL DEFAULT(1)
END

