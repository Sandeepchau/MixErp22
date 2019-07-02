ALTER TABLE inventory.inventory_setup
ADD COLUMN IF NOT EXISTS validate_returns boolean NOT NULL DEFAULT(true);
