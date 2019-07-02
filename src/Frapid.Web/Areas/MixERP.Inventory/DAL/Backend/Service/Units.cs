using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.Inventory.DTO;

namespace MixERP.Inventory.DAL.Backend.Service
{
    public static class Units
    {
        public static async Task<List<AssociatedUnit>> GetAssociatedUnitsAsync(string tenant, string itemCode)
        {
            string sql = "SELECT * FROM inventory.get_associated_units_by_item_code(@0);";
            var result = await Factory.GetAsync<AssociatedUnit>(tenant, sql, itemCode).ConfigureAwait(false);
            return result.ToList();
        }
    }
}