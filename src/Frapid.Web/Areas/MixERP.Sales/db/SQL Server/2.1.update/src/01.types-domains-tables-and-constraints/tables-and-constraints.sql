ALTER TABLE sales.returns
ALTER COLUMN sales_id bigint NULL;

ALTER TABLE sales.returns
ALTER COLUMN transaction_master_id bigint NULL;

IF COL_LENGTH('sales.orders', 'priority') IS NULL
BEGIN
	ALTER TABLE sales.orders 
	ADD [priority] national character varying(24);
END;

IF COL_LENGTH('sales.customerwise_selling_prices', 'is_taxable') IS NULL
BEGIN
	ALTER TABLE sales.customerwise_selling_prices
	ADD is_taxable bit NOT NULL DEFAULT(0);
END;

