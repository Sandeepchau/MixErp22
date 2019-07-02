using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.DataAccess;
using Frapid.Mapper;

namespace MixERP.Inventory.DAL.Backend.Setup
{
    public static class InventorySetup
    {
        public static async Task<DTO.InventorySetup> GetAsync(string tenant, int officeId)
        {
            const string sql = "SELECT * FROM inventory.inventory_setup WHERE office_id=@0;";
            var awaiter = await Factory.GetAsync<DTO.InventorySetup>(tenant, sql, officeId).ConfigureAwait(false);

            return awaiter.FirstOrDefault();
        }

        public static async Task<IEnumerable<DTO.InventorySetup>> GetAsync(string tenant)
        {
            const string sql = "SELECT * FROM inventory.inventory_setup;";
            return await Factory.GetAsync<DTO.InventorySetup>(tenant, sql).ConfigureAwait(false);
        }

        public static async Task SetAsync(string tenant, int officeId, DTO.InventorySetup model)
        {
            var sql = new Sql("UPDATE inventory.inventory_setup");
            sql.Append(" SET ");
            sql.Append("inventory_system = @0,", model.InventorySystem);
            sql.Append("cogs_calculation_method = @0,", model.CogsCalculationMethod);
            sql.Append("allow_multiple_opening_inventory = @0,", model.AllowMultipleOpeningInventory);
            sql.Append("default_discount_account_id = @0,", model.DefaultDiscountAccountId);
            sql.Append("validate_returns = @0,", model.ValidateReturns);
            sql.Append("use_pos_checkout_screen = @0", model.UsePosCheckoutScreen);
            sql.Where("office_id = @0", officeId);

            await Factory.NonQueryAsync(tenant, sql).ConfigureAwait(false);
        }
    }
}