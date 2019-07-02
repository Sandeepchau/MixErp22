EXECUTE dbo.drop_schema 'inventory';
GO
CREATE SCHEMA inventory;
GO

CREATE TABLE inventory.units
(
    unit_id                                 integer IDENTITY PRIMARY KEY,
    unit_code                               national character varying(24) NOT NULL,
    unit_name                               national character varying(500) NOT NULL,    
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX units_unit_code_uix
ON inventory.units(unit_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX units_unit_name_uix
ON inventory.units(unit_name)
WHERE deleted = 0;

CREATE TABLE inventory.compound_units
(
    compound_unit_id                        integer IDENTITY PRIMARY KEY,
    base_unit_id                            integer NOT NULL REFERENCES inventory.units,
    value                                   smallint NOT NULL DEFAULT(0) CHECk(value > 0),
    compare_unit_id                         integer NOT NULL REFERENCES inventory.units,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX compound_units_base_unit_id_value_uix
ON inventory.compound_units(base_unit_id, value)
WHERE deleted = 0;

CREATE TABLE inventory.supplier_types
(
    supplier_type_id                        integer IDENTITY PRIMARY KEY,
    supplier_type_code                      national character varying(24) NOT NULL,
    supplier_type_name                      national character varying(500) NOT NULL,
    account_id                                integer NOT NULL REFERENCES finance.accounts,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX supplier_types_supplier_type_code_uix
ON inventory.supplier_types(supplier_type_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX supplier_types_supplier_type_name_uix
ON inventory.supplier_types(supplier_type_name)
WHERE deleted = 0;

CREATE TABLE inventory.suppliers
(
    supplier_id                             integer IDENTITY PRIMARY KEY,
    supplier_code                           national character varying(24) NOT NULL,
    supplier_name                           national character varying(500) NOT NULL,
    supplier_type_id                        integer NOT NULL REFERENCES inventory.supplier_types,
    account_id                              integer REFERENCES finance.accounts,
    email                                   national character varying(128),
    currency_code                           national character varying(12) NOT NULL REFERENCES core.currencies,
    company_name                            national character varying(1000),
	pan_number								national character varying(100),
    company_address_line_1                  national character varying(128),   
    company_address_line_2                  national character varying(128),
    company_street                          national character varying(1000),
    company_city                            national character varying(1000),
    company_state                           national character varying(1000),
    company_country                         national character varying(1000),
    company_po_box                          national character varying(1000),
    company_zip_code                        national character varying(1000),
    company_phone_numbers                   national character varying(1000),
    company_fax                             national character varying(100),
    logo                                    dbo.photo,
    contact_first_name                      national character varying(100),
    contact_middle_name                     national character varying(100),
    contact_last_name                       national character varying(100),
    contact_address_line_1                  national character varying(128),   
    contact_address_line_2                  national character varying(128),
    contact_street                          national character varying(100),
    contact_city                            national character varying(100),
    contact_state                           national character varying(100),
    contact_country                         national character varying(100),
    contact_po_box                          national character varying(100),
    contact_zip_code                        national character varying(100),
    contact_phone_numbers                   national character varying(100),
    contact_fax                             national character varying(100),
    photo                                   dbo.photo,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX suppliers_supplier_code_uix
ON inventory.suppliers(supplier_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX suppliers_account_id_uix
ON inventory.suppliers(account_id)
WHERE deleted = 0
AND account_id IS NOT NULL;

CREATE TABLE inventory.customer_types
(
    customer_type_id                        integer IDENTITY PRIMARY KEY,
    customer_type_code                      national character varying(24) NOT NULL,
    customer_type_name                      national character varying(500) NOT NULL,
    account_id                              integer NOT NULL REFERENCES finance.accounts,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX customer_types_customer_type_code_uix
ON inventory.customer_types(customer_type_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX customer_types_customer_type_name_uix
ON inventory.customer_types(customer_type_name)
WHERE deleted = 0;

CREATE TABLE inventory.customers
(
    customer_id                             integer IDENTITY PRIMARY KEY,
    customer_code                           national character varying(24) NOT NULL,
    customer_name                           national character varying(500) NOT NULL,
    customer_type_id                        integer NOT NULL REFERENCES inventory.customer_types,
    account_id                              integer REFERENCES finance.accounts,
    email                                   national character varying(128),
    currency_code                           national character varying(12) NOT NULL REFERENCES core.currencies,
    company_name                            national character varying(1000),
    company_address_line_1                  national character varying(128),   
    company_address_line_2                  national character varying(128),
    company_street                          national character varying(1000),
    company_city                            national character varying(1000),
    company_state                           national character varying(1000),
    company_country                         national character varying(1000),
    company_po_box                          national character varying(1000),
    company_zip_code                        national character varying(1000),
    company_phone_numbers                   national character varying(1000),
    company_fax                             national character varying(100),
    logo                                    dbo.photo,
    contact_first_name                      national character varying(100),
    contact_middle_name                     national character varying(100),
    contact_last_name                       national character varying(100),
    contact_address_line_1                  national character varying(128),   
    contact_address_line_2                  national character varying(128),
    contact_street                          national character varying(100),
    contact_city                            national character varying(100),
    contact_state                           national character varying(100),
    contact_country                         national character varying(100),
    contact_po_box                          national character varying(100),
    contact_zip_code                        national character varying(100),
    contact_phone_numbers                   national character varying(100),
    contact_fax                             national character varying(100),
    photo                                   dbo.photo,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX customers_customer_code_uix
ON inventory.customers(customer_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX customers_account_id_uix
ON inventory.customers(account_id)
WHERE deleted = 0
AND account_id IS NOT NULL;

CREATE TABLE inventory.item_groups
(
    item_group_id                           integer IDENTITY PRIMARY KEY,
    item_group_code                         national character varying(24) NOT NULL,
    item_group_name                         national character varying(500) NOT NULL,
    exclude_from_purchase                   bit NOT NULL DEFAULT(0),
    exclude_from_sales                      bit NOT NULL DEFAULT(0),    
    sales_account_id                        integer NOT NULL REFERENCES finance.accounts,
    sales_discount_account_id               integer NOT NULL REFERENCES finance.accounts,
    sales_return_account_id                 integer NOT NULL REFERENCES finance.accounts,
    purchase_account_id                     integer NOT NULL REFERENCES finance.accounts,
    purchase_discount_account_id            integer NOT NULL REFERENCES finance.accounts,
    inventory_account_id                    integer NOT NULL REFERENCES finance.accounts,
    cost_of_goods_sold_account_id           integer NOT NULL REFERENCES finance.accounts,    
    parent_item_group_id                    integer REFERENCES inventory.item_groups(item_group_id),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)    
);

CREATE UNIQUE INDEX item_groups_item_group_code_uix
ON inventory.item_groups(item_group_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX item_groups_item_group_name_uix
ON inventory.item_groups(item_group_name)
WHERE deleted = 0;

CREATE TABLE inventory.brands
(
    brand_id                                integer IDENTITY PRIMARY KEY,
    brand_code                              national character varying(24) NOT NULL,
    brand_name                              national character varying(500) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)    
);

CREATE UNIQUE INDEX brands_brand_code_uix
ON inventory.brands(brand_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX brands_brand_name_uix
ON inventory.brands(brand_name)
WHERE deleted = 0;

CREATE TABLE inventory.item_types
(
    item_type_id                            integer IDENTITY PRIMARY KEY,
    item_type_code                          national character varying(12) NOT NULL,
    item_type_name                          national character varying(50) NOT NULL,
    is_component                            bit NOT NULL DEFAULT(0),
    audit_user_id                           integer NULL REFERENCES account.users(user_id),
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)    
);


CREATE UNIQUE INDEX item_type_item_type_code_uix
ON inventory.item_types(item_type_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX item_type_item_type_name_uix
ON inventory.item_types(item_type_name)
WHERE deleted = 0;


CREATE TABLE inventory.items
(
    item_id                                 integer IDENTITY PRIMARY KEY,
    item_code                               national character varying(24) NOT NULL,
    item_name                               national character varying(500) NOT NULL,
    barcode                                 national character varying(100), --UNIQUE
    item_group_id                           integer NOT NULL REFERENCES inventory.item_groups,
    item_type_id                            integer NOT NULL REFERENCES inventory.item_types,
    brand_id                                integer REFERENCES inventory.brands,
    preferred_supplier_id                   integer REFERENCES inventory.suppliers,
    lead_time_in_days                       integer,
    unit_id                                 integer NOT NULL REFERENCES inventory.units,
    hot_item                                bit NOT NULL DEFAULT(0),
    is_taxable_item                         bit NOT NULL DEFAULT(1),
    cost_price                              numeric(30, 6),
    cost_price_includes_tax                 bit NOT NULL DEFAULT(0),
    selling_price                           numeric(30, 6),
    selling_price_includes_tax              bit NOT NULL DEFAULT(0),
    reorder_level                           integer NOT NULL DEFAULT(0),
    reorder_quantity                        numeric(30, 6) NOT NULL DEFAULT(0),
    reorder_unit_id                         integer NOT NULL REFERENCES inventory.units,
    maintain_inventory                      bit NOT NULL DEFAULT(1),
    photo                                   dbo.photo,
    allow_sales                             bit NOT NULL DEFAULT(1),
    allow_purchase                          bit NOT NULL DEFAULT(1),
    is_variant_of                           integer REFERENCES inventory.items,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)    
);

CREATE UNIQUE INDEX items_item_code_uix
ON inventory.items(item_code)
WHERE deleted = 0;

CREATE TABLE inventory.store_types
(
    store_type_id                           integer IDENTITY PRIMARY KEY,
    store_type_code                         national character varying(12) NOT NULL,
    store_type_name                         national character varying(50) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)    
);

CREATE UNIQUE INDEX store_types_store_type_code_uix
ON inventory.store_types(store_type_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX store_types_store_type_name_uix
ON inventory.store_types(store_type_name)
WHERE deleted = 0;

CREATE TABLE inventory.stores
(
    store_id                                integer IDENTITY PRIMARY KEY,
    store_code                              national character varying(24) NOT NULL,
    store_name                              national character varying(500) NOT NULL,
    store_type_id                           integer NOT NULL REFERENCES inventory.store_types,
    office_id                                integer NOT NULL REFERENCES core.offices,
    default_account_id_for_checks           integer NOT NULL REFERENCES finance.accounts,
    default_cash_account_id                 integer NOT NULL REFERENCES finance.accounts,
    default_cash_repository_id              integer NOT NULL REFERENCES finance.cash_repositories,
    address_line_1                          national character varying(128),   
    address_line_2                          national character varying(128),
    street                                  national character varying(50),
    city                                    national character varying(50),
    state                                   national character varying(50),
    country                                 national character varying(50),
    phone                                   national character varying(50),
    fax                                     national character varying(50),
    cell                                    national character varying(50),
    allow_sales                             bit NOT NULL DEFAULT(1),    
	sales_discount_account_id				integer NOT NULL REFERENCES finance.accounts DEFAULT(finance.get_account_id_by_account_number('40270')),
	purchase_discount_account_id			integer NOT NULL REFERENCES finance.accounts DEFAULT(finance.get_account_id_by_account_number('30700')),
	shipping_expense_account_id				integer NOT NULL REFERENCES finance.accounts DEFAULT(finance.get_account_id_by_account_number('43000')),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)    
);

CREATE UNIQUE INDEX stores_store_code_uix
ON inventory.stores(store_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX stores_store_name_uix
ON inventory.stores(store_name)
WHERE deleted = 0;

CREATE TABLE inventory.counters
(
    counter_id                              integer IDENTITY PRIMARY KEY,
    counter_code                            national character varying(12) NOT NULL,
    counter_name                            national character varying(100) NOT NULL,
    store_id                                integer NOT NULL REFERENCES inventory.stores,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX counters_counter_code_uix
ON inventory.counters(counter_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX counters_counter_name_uix
ON inventory.counters(counter_name)
WHERE deleted = 0;

CREATE TABLE inventory.shippers
(
    shipper_id                              integer IDENTITY PRIMARY KEY,
    shipper_code                            national character varying(24),
    company_name                            national character varying(128) NOT NULL,
    shipper_name                            national character varying(150),
    po_box                                  national character varying(128),
    address_line_1                          national character varying(128),   
    address_line_2                          national character varying(128),
    street                                  national character varying(50),
    city                                    national character varying(50),
    state                                   national character varying(50),
    country                                 national character varying(50),
    phone                                   national character varying(50),
    fax                                     national character varying(50),
    cell                                    national character varying(50),
    email                                   national character varying(128),
    url                                     national character varying(50),
    contact_person                          national character varying(50),
    contact_po_box                          national character varying(128),
    contact_address_line_1                  national character varying(128),   
    contact_address_line_2                  national character varying(128),
    contact_street                          national character varying(50),
    contact_city                            national character varying(50),
    contact_state                           national character varying(50),
    contact_country                         national character varying(50),
    contact_email                           national character varying(128),
    contact_phone                           national character varying(50),
    contact_cell                            national character varying(50),
    factory_address                         national character varying(250),
    pan_number                              national character varying(50),
    sst_number                              national character varying(50),
    cst_number                              national character varying(50),
    account_id                              integer NOT NULL REFERENCES finance.accounts(account_id),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX shippers_shipper_code_uix
ON inventory.shippers(shipper_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX shippers_shipper_name_uix
ON inventory.shippers(shipper_name)
WHERE deleted = 0;

CREATE TABLE inventory.checkouts
(
    checkout_id                             bigint IDENTITY PRIMARY KEY,
    value_date                              date NOT NULL,
    book_date                               date NOT NULL,
    transaction_master_id                   bigint NOT NULL REFERENCES finance.transaction_master,
    transaction_timestamp                   DATETIMEOFFSET NOT NULL DEFAULT(GETUTCDATE()),
    transaction_book                        national character varying(100) NOT NULL, --SALES, PURCHASE, INVENTORY TRANSFER, DAMAGE
	taxable_total							numeric(30, 6) DEFAULT(0),
	discount								numeric(30, 6) DEFAULT(0),
	tax_rate								numeric(30, 6) DEFAULT(0),
	tax										numeric(30, 6) DEFAULT(0),	
	nontaxable_total						numeric(30, 6) DEFAULT(0),
    posted_by                               integer NOT NULL REFERENCES account.users,
    /*LOOKUP FIELDS, ONLY TO SPEED UP THE QUERY */
    office_id                               integer NOT NULL REFERENCES core.offices,
    /*LOOKUP FIELDS */    
    cancelled                               bit NOT NULL DEFAULT(0),
    cancellation_reason                        national character varying(1000),
    shipper_id                                integer REFERENCES inventory.shippers,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)    
);

CREATE INDEX checkouts_transaction_master_id_inx
ON inventory.checkouts(transaction_master_id);

CREATE TABLE inventory.checkout_details
(
    checkout_detail_id                      bigint IDENTITY PRIMARY KEY,
    checkout_id                             bigint NOT NULL REFERENCES inventory.checkouts,
    store_id                                integer NOT NULL REFERENCES inventory.stores,
    value_date                              date NOT NULL,
    book_date                               date NOT NULL,
    transaction_type                        national character varying(2) NOT NULL
                                            CHECK(transaction_type IN('Dr', 'Cr')),
    item_id                                 integer NOT NULL REFERENCES inventory.items,
    price                                   numeric(30, 6) NOT NULL,
	discount_rate 							numeric(30, 6) NOT NULL DEFAULT(0),
    discount                                numeric(30, 6) NOT NULL DEFAULT(0),    
    cost_of_goods_sold                      numeric(30, 6) NOT NULL DEFAULT(0),
	is_taxed								bit NOT NULL DEFAULT(1),
    shipping_charge                         numeric(30, 6) NOT NULL DEFAULT(0),    
    unit_id                                 integer NOT NULL REFERENCES inventory.units,
    quantity                                numeric(30, 6) NOT NULL,
    base_unit_id                            integer NOT NULL REFERENCES inventory.units,
    base_quantity                           numeric(30, 6) NOT NULL,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE())
);

CREATE TABLE inventory.inventory_transfer_requests
(
    inventory_transfer_request_id           bigint IDENTITY PRIMARY KEY,
    office_id                               integer NOT NULL REFERENCES core.offices,
    user_id                                 integer NOT NULL REFERENCES account.users,
    store_id                                integer NOT NULL REFERENCES inventory.stores,
    request_date                            date NOT NULL,
    transaction_timestamp                   DATETIMEOFFSET NOT NULL DEFAULT(GETUTCDATE()),
    reference_number                        national character varying(24),
    statement_reference                     national character varying(2000),
    authorized                              bit NOT NULL DEFAULT(0),
    authorized_by_user_id                   integer REFERENCES account.users,
    authorized_on                           DATETIMEOFFSET,
    authorization_reason                    national character varying(500),
    rejected                                bit NOT NULL DEFAULT(0),
    rejected_by_user_id                     integer REFERENCES account.users,
    rejected_on                             DATETIMEOFFSET,
    rejection_reason                        national character varying(500),
    received                                bit NOT NULL DEFAULT(0),
    received_by_user_id                     integer REFERENCES account.users,
    received_on                             DATETIMEOFFSET,
    receipt_memo                            national character varying(500),
    delivered                               bit NOT NULL DEFAULT(0),
    delivered_by_user_id                    integer REFERENCES account.users,
    delivered_on                            DATETIMEOFFSET,
    delivery_memo                           national character varying(500),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)    
);

CREATE TABLE inventory.inventory_transfer_request_details
(
    inventory_transfer_request_detail_id    bigint IDENTITY PRIMARY KEY,
    inventory_transfer_request_id           bigint NOT NULL REFERENCES inventory.inventory_transfer_requests,
    request_date                            date NOT NULL,
    item_id                                 integer NOT NULL REFERENCES inventory.items,
    quantity                                numeric(30, 6) NOT NULL,
    unit_id                                 integer NOT NULL REFERENCES inventory.units,
    base_unit_id                            integer NOT NULL REFERENCES inventory.units,
    base_quantity                           numeric(30, 6) NOT NULL
);

CREATE TABLE inventory.inventory_transfer_deliveries
(
    inventory_transfer_delivery_id          bigint IDENTITY PRIMARY KEY,
    inventory_transfer_request_id           bigint NOT NULL REFERENCES inventory.inventory_transfer_requests,
    office_id                               integer NOT NULL REFERENCES core.offices,
    user_id                                 integer NOT NULL REFERENCES account.users,
    destination_store_id                    integer NOT NULL REFERENCES inventory.stores,
    delivery_date                           date NOT NULL,
    transaction_timestamp                   DATETIMEOFFSET NOT NULL DEFAULT(GETUTCDATE()),
    reference_number                        national character varying(24),
    statement_reference                     national character varying(2000),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);


CREATE TABLE inventory.inventory_transfer_delivery_details
(
    inventory_transfer_delivery_detail_id   bigint IDENTITY PRIMARY KEY,
    inventory_transfer_delivery_id          bigint NOT NULL REFERENCES inventory.inventory_transfer_deliveries,
    request_date                            date NOT NULL,
    item_id                                 integer NOT NULL REFERENCES inventory.items,
    quantity                                numeric(30, 6) NOT NULL,
    unit_id                                 integer NOT NULL REFERENCES inventory.units,
    base_unit_id                            integer NOT NULL REFERENCES inventory.units,
    base_quantity                           numeric(30, 6) NOT NULL
);


CREATE TABLE inventory.attributes
(
    attribute_id                            integer IDENTITY NOT NULL PRIMARY KEY,
    attribute_code                          national character varying(12) NOT NULL UNIQUE,
    attribute_name                          national character varying(100) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX attributes_attribute_code_uix
ON inventory.attributes(attribute_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX attributes_attribute_name_uix
ON inventory.attributes(attribute_name)
WHERE deleted = 0;

CREATE TABLE inventory.variants
(
    variant_id                              integer IDENTITY NOT NULL PRIMARY KEY,
    variant_code                            national character varying(12) NOT NULL UNIQUE,
    variant_name                            national character varying(100) NOT NULL,
    attribute_id                            integer NOT NULL REFERENCES inventory.attributes,
    attribute_value                         national character varying(200) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX variants_variant_code_uix
ON inventory.variants(variant_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX variants_variant_name_uix
ON inventory.variants(variant_name)
WHERE deleted = 0;

CREATE TABLE inventory.item_variants
(
    item_variant_id                         integer IDENTITY NOT NULL PRIMARY KEY,
    item_id                                 integer NOT NULL REFERENCES inventory.items,
    variant_id                              integer NOT NULL REFERENCES inventory.variants,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE TABLE inventory.inventory_setup
(
    office_id                               integer NOT NULL PRIMARY KEY REFERENCES core.offices,
    inventory_system                        national character varying(50) NOT NULL
                                            CHECK(inventory_system IN('Periodic', 'Perpetual')),
    cogs_calculation_method                 national character varying(50) NOT NULL
                                            CHECK(cogs_calculation_method IN('FIFO', 'LIFO', 'MAVCO')),
    allow_multiple_opening_inventory        bit NOT NULL DEFAULT(0),
    default_discount_account_id             integer NOT NULL REFERENCES finance.accounts,
	use_pos_checkout_screen					bit NOT NULL DEFAULT(1)
);

CREATE TYPE inventory.transfer_type
AS TABLE
(
    tran_type       national character varying(2),
    store_name      national character varying(500),
    item_code       national character varying(24),
    unit_name       national character varying(500),
    quantity        numeric(30, 6),
    rate            numeric(30, 6)
);

CREATE TYPE inventory.adjustment_type 
AS TABLE
(
    tran_type       national character varying(2),
    item_code       national character varying(24),
    unit_name       national character varying(500),
    quantity        numeric(30, 6)
);


CREATE TYPE inventory.checkout_detail_type
AS TABLE
(
    store_id            integer,
    item_id               integer,
    quantity            numeric(30, 6),
    unit_id               national character varying(50),
    price               numeric(30, 6),
    discount            numeric(30, 6),
    tax                 numeric(30, 6),
    shipping_charge     numeric(30, 6)
);


CREATE TYPE inventory.opening_stock_type
AS TABLE
(
    store_id            integer,
    item_id               integer,
    quantity            numeric(30, 6),
    unit_id               integer,
    price                  numeric(30, 6)
);


CREATE TABLE inventory.serial_numbers
(
	serial_number_id					BIGINT IDENTITY NOT NULL PRIMARY KEY,
	item_id								int NOT NULL REFERENCES inventory.items,
	unit_id								int NOT NULL REFERENCES inventory.units,
	store_id							int NOT NULL REFERENCES inventory.stores,
	transaction_type					national character varying(2) NOT NULL,
	checkout_id							bigint NOT NULL REFERENCES inventory.checkouts,
	batch_number						national character varying(50) NOT NULL,
	serial_number						national character varying(150) NOT NULL,
	expiry_date							datetime,
	sales_transaction_id				bigint REFERENCES finance.transaction_master,
	deleted								bit NOT NULL DEFAULT(0)
);

GO
