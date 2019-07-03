using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.Mapper;
using Frapid.Mapper.Query.Insert;
using Frapid.Mapper.Query.NonQuery;
using Frapid.Mapper.Query.Select;
using MixERP.Sales.DTO;

namespace MixERP.Sales.DAL.Backend.Setup
{
    public static class SellingPrices
    {
        public static async Task<IEnumerable<dynamic>> GetSellingPrices(string tenant, int officeId, int customerId)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql(@"WITH price_list
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
	                                    inventory.items.unit_id,
	                                    inventory.get_unit_name_by_unit_id(inventory.items.unit_id) AS unit,
	                                    COALESCE(price_list.price, sales.get_item_selling_price(@1, inventory.items.item_id, NULL, NULL, inventory.items.unit_id)) AS price,
										price_list.is_taxable
                                    FROM inventory.items
                                    LEFT JOIN price_list
                                    ON price_list.item_id = inventory.items.item_id
                                    WHERE inventory.items.allow_sales = @2
                                    AND (price_list.customer_id IS NULL OR price_list.customer_id = @0);", customerId, officeId, true);

                return await db.SelectAsync<dynamic>(sql).ConfigureAwait(false);
            }
        }

        public static async Task SetPriceList(string tenant, int userId, int customerId, IEnumerable<CustomerwiseSellingPrice> pricelist)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                try
                {
                    await db.BeginTransactionAsync().ConfigureAwait(false);

                    var sql = new Sql("DELETE FROM sales.customerwise_selling_prices");
                    sql.Where("customer_id = @0", customerId);

                    await db.NonQueryAsync(sql).ConfigureAwait(false);

                    foreach (var price in pricelist)
                    {
                        price.CustomerId = customerId;
                        price.AuditUserId = userId;
                        price.AuditTs = DateTimeOffset.UtcNow;
                        price.Deleted = false;

                        await db.InsertAsync(price).ConfigureAwait(false);
                    }

                    db.CommitTransaction();
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }
    }
}