ALTER TABLE sales.returns
ALTER COLUMN sales_id DROP NOT NULL;

ALTER TABLE sales.returns
ALTER COLUMN transaction_master_id DROP NOT NULL;

ALTER TABLE sales.customerwise_selling_prices
ADD COLUMN IF NOT EXISTS is_taxable boolean NOT NULL DEFAULT(false);
