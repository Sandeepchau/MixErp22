using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.Inventory.DTO;

namespace MixERP.Inventory.DAL.Backend.Tasks
{
    public static class Stores
    {
        public static async Task<List<ClosingInventory>> GetClosingInventoryAsync(string tenant, int storeId)
        {
            const string sql = "SELECT * FROM inventory.list_closing_stock(@0);";
            var awaiter = await Factory.GetAsync<ClosingInventory>(tenant, sql, storeId).ConfigureAwait(false);

            return awaiter.ToList();
        }

        public static async Task<List<QueryModels.DisplayField>> GetSalesStores(string tenant)
        {
            const string sql = "SELECT store_id AS \"key\", store_name AS \"value\" FROM inventory.stores WHERE allow_sales=1";
            var awaiter = await Factory.GetAsync<QueryModels.DisplayField>(tenant, sql).ConfigureAwait(false);

            return awaiter.ToList();
        }
    }
}