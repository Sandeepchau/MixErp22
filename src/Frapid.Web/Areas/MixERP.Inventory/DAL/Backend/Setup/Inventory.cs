using System.Linq;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.Inventory.DTO;

namespace MixERP.Inventory.DAL.Backend.Setup
{
    public static class Inventory
    {
        public static async Task<OpeningInventoryStatus> GetOpeningStatusAsync(string tenant, int officeId)
        {
            const string sql = "SELECT * FROM inventory.get_opening_inventory_status(@0);";
            var awaiter = await Factory.GetAsync<OpeningInventoryStatus>(tenant, sql, officeId).ConfigureAwait(false);

            return awaiter.FirstOrDefault();
        }

        public static async Task<decimal> GetCogs(string tenant, int itemId, int unitId, int storeId, decimal quantity)
        {
            const string sql = "SELECT inventory.get_cost_of_goods_sold(@0, @1, @2, @3);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, itemId, unitId, storeId, quantity).ConfigureAwait(false);
        }
    }
}