using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.DataAccess;
using Frapid.DataAccess.Extensions;
using Frapid.Framework.Extensions;
using MixERP.Inventory.DTO;

namespace MixERP.Inventory.DAL.Backend.Setup.Variants
{
    public sealed class SqlServer : IItemVariant
    {
        public async Task<int> CreateAsync(string tenant, ItemVariantInfo variant)
        {
            string connectionString = FrapidDbServer.GetConnectionString(tenant);

            string sql = "EXECUTE inventory.create_item_variant @VariantOf, @ItemId, @ItemCode, @ItemName, @Variants, @UserId, @VariantId OUTPUT";

            using (var connection = new SqlConnection(connectionString))
            {
                using (var command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithNullableValue("@VariantOf", variant.VariantOf);
                    command.Parameters.AddWithNullableValue("@ItemId", variant.ItemId);
                    command.Parameters.AddWithNullableValue("@ItemCode", variant.ItemCode);
                    command.Parameters.AddWithNullableValue("@ItemName", variant.ItemName);
                    command.Parameters.AddWithNullableValue("@Variants", "{" + string.Join(",", variant.Variants) + "}");
                    command.Parameters.AddWithNullableValue("@UserId", variant.UserId);

                    command.Parameters.Add("@VariantId", SqlDbType.Int).Direction = ParameterDirection.Output;

                    connection.Open();
                    await command.ExecuteNonQueryAsync().ConfigureAwait(false);

                    return command.Parameters["@VariantId"].Value.To<int>();
                }
            }
        }


        public async Task DeleteAsync(string tenant, int itemId)
        {
            string sql = "EXECUTE inventory.delete_variant_item @0;";
            await Factory.NonQueryAsync(tenant, sql, itemId).ConfigureAwait(false);
        }

    }
}