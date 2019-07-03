using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Mapper;
using Frapid.Mapper.Query.Select;
using MixERP.Sales.DTO;

namespace MixERP.Sales.DAL.Backend.Service
{
    public static class Items
    {
        public static async Task<IEnumerable<ItemView>> GetItemsAsync(string tenant, int officeId, int? customerId)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT *, finance.get_sales_tax_rate(@0) AS sales_tax_rate FROM sales.item_view;", officeId);

                if (customerId != null && customerId > 0)
                {
                    sql = new Sql(@"WITH price_list
					AS
					(
					    SELECT * FROM sales.customerwise_selling_prices
					    WHERE 
					    (
					        sales.customerwise_selling_prices.customer_id IS NULL 
					        OR sales.customerwise_selling_prices.customer_id = @0
					    )
					)					
					SELECT
					        inventory.items.item_id,
					        inventory.items.item_code,
					        inventory.items.item_name,
					        inventory.items.barcode,
					        inventory.items.item_group_id,
					        inventory.item_groups.item_group_name,
					        inventory.item_types.item_type_id,
					        inventory.item_types.item_type_name,
					        inventory.items.brand_id,
					        inventory.brands.brand_name,
					        inventory.items.preferred_supplier_id,
					        inventory.items.unit_id,
					        inventory.get_associated_unit_list_csv(inventory.items.unit_id) AS valid_units,
					        inventory.units.unit_code,
					        inventory.units.unit_name,
					        inventory.items.hot_item,
					        inventory.items.selling_price,
					        inventory.items.selling_price_includes_tax,
					        inventory.items.photo,
					COALESCE(price_list.is_taxable, inventory.items.is_taxable_item) AS is_taxable_item,
					    COALESCE(price_list.price, sales.get_item_selling_price(@1, inventory.items.item_id, NULL, NULL, inventory.items.unit_id)) AS selling_price
					FROM inventory.items
					    INNER JOIN inventory.item_groups
					    ON inventory.item_groups.item_group_id = inventory.items.item_group_id
					    INNER JOIN inventory.item_types
					    ON inventory.item_types.item_type_id = inventory.items.item_type_id
					    INNER JOIN inventory.brands
					    ON inventory.brands.brand_id = inventory.items.brand_id
					    INNER JOIN inventory.units
					    ON inventory.units.unit_id = inventory.items.unit_id
					LEFT JOIN price_list
					ON price_list.item_id = inventory.items.item_id
					    WHERE inventory.items.deleted = 0
					    AND inventory.items.allow_sales = 1
					AND (price_list.customer_id IS NULL OR price_list.customer_id = @0)", customerId, officeId);

                }

                return await db.SelectAsync<ItemView>(sql).ConfigureAwait(false);
            }
        }

        public static async Task<decimal> GetSellingPriceAsync(string tenant, int officeId,  int itemId, int customerId, int priceTypeId, int unitId)
        {
            const string sql = "SELECT sales.get_selling_price(@0, @1, @2, @3, @4);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, officeId, itemId, customerId, priceTypeId, unitId).ConfigureAwait(false);
        }

        public static async Task<IEnumerable<ViewModels.ItemSerialNumber>> GetSerialNumbersAsync(string tenant, int itemId, int unitId, int storeId)
        {
            const string sql = @"SELECT serial_number_id, item_name, unit_code, batch_number, serial_number, expiry_date
                    FROM inventory.serial_numbers_view WHERE sales_transaction_id IS NULL
                    AND item_id=@0 AND unit_id=@1 AND store_id=@2 ORDER BY expiry_date ASC;";

            return await Factory.GetAsync<ViewModels.ItemSerialNumber>(tenant, sql, itemId, unitId, storeId)
                .ConfigureAwait(false);
        }
    }
}