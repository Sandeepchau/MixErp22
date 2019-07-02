using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Mapper;
using Frapid.Mapper.Query.Select;
using MixERP.Inventory.DTO;

namespace MixERP.Inventory.DAL.Backend.Service
{
    public static class Items
    {
        public static async Task<IEnumerable<ItemView>> GetStockableItemViewAsync(string tenant)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM inventory.item_view");
                sql.Where("maintain_inventory=@0", true);

                return await db.SelectAsync<ItemView>(sql).ConfigureAwait(false);
            }
        }

        public static async Task<IEnumerable<Item>> GetStockableItemsAsync(string tenant)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM inventory.items");
                sql.Where("deleted=@0", false);
                sql.And("maintain_inventory=@0", true);

                return await db.SelectAsync<Item>(sql).ConfigureAwait(false);
            }
        }

        public static async Task<decimal> GetCostPriceAsync(string tenant, int itemId, int unitId)
        {
            const string sql = "SELECT inventory.get_item_cost_price(@0, @1);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, itemId, unitId).ConfigureAwait(false);
        }

        public static async Task<decimal> CountItemsByItemCodeAsync(string tenant, string itemCode, string unitName, string storeName)
        {
            const string sql = "SELECT inventory.count_item_in_stock(inventory.get_item_id_by_item_code(@0), inventory.get_unit_id_by_unit_name(@1), inventory.get_store_id_by_store_name(@2));";
            return await Factory.ScalarAsync<decimal>(tenant, sql, itemCode, unitName, storeName).ConfigureAwait(false);
        }

        public static async Task<decimal> CountItemsAsync(string tenant, int itemId, int unitId, int storeId)
        {
            const string sql = "SELECT inventory.count_item_in_stock(@0, @1, @2);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, itemId, unitId, storeId).ConfigureAwait(false);
        }

        public static async Task<IEnumerable<Item>> GetNonStockableItemsAsync(string tenant)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM inventory.items");
                sql.Where("deleted=@0", false);
                sql.And("maintain_inventory=@0", false);

                return await db.SelectAsync<Item>(sql).ConfigureAwait(false);
            }
        }
    }
}