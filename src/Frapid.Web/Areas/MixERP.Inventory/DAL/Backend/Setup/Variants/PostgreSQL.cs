using System.Threading.Tasks;
using Frapid.DataAccess;
using MixERP.Inventory.DTO;

namespace MixERP.Inventory.DAL.Backend.Setup.Variants
{
    public sealed class PostgreSQL : IItemVariant
    {
        public async Task<int> CreateAsync(string tenant, ItemVariantInfo variant)
        {
            string sql = "SELECT * FROM inventory.create_item_variant(@0,@1,@2,@3,@4,@5);";

            string variants = "{" + string.Join(",", variant.Variants) + "}";
            return await Factory.ScalarAsync<int>(tenant, sql, variant.VariantOf, variant.ItemId, variant.ItemCode, variant.ItemName, variants, variant.UserId).ConfigureAwait(false);
        }

        public async Task DeleteAsync(string tenant, int itemId)
        {
            string sql = "SELECT * FROM inventory.delete_variant_item(@0);";
            await Factory.NonQueryAsync(tenant, sql, itemId).ConfigureAwait(false);
        }
    }
}