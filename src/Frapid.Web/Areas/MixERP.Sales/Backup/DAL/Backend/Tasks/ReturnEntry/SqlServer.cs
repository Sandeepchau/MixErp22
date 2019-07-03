using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.DataAccess.Extensions;
using Frapid.Framework.Extensions;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.DAL.Backend.Tasks.ReturnEntry
{
    public sealed class SqlServer : IReturnEntry
    {
        public async Task<long> PostAsync(string tenant, SalesReturn model)
        {
            string connectionString = FrapidDbServer.GetConnectionString(tenant);
            const string sql = @"EXECUTE sales.post_return
                                @TransactionMasterId, @OfficeId, @UserId, @LoginId, 
                                @ValueDate, @BookDate, 
                                @StoreId, @CounterId, @CustomerId, @PriceTypeId,
                                @ReferenceNumber, @StatementReference, 
                                @Details, @ShipperId, @Discount, @TranId OUTPUT
                            ";

            using (var connection = new SqlConnection(connectionString))
            {

                using (var command = new SqlCommand(sql, connection))
                {

                    command.Parameters.AddWithNullableValue("@TransactionMasterId", model.TransactionMasterId);
                    command.Parameters.AddWithNullableValue("@OfficeId", model.OfficeId);
                    command.Parameters.AddWithNullableValue("@UserId", model.UserId);
                    command.Parameters.AddWithNullableValue("@LoginId", model.LoginId);
                    command.Parameters.AddWithNullableValue("@ValueDate", model.ValueDate);
                    command.Parameters.AddWithNullableValue("@BookDate", model.BookDate);

                    command.Parameters.AddWithNullableValue("@StoreId", model.StoreId);
                    command.Parameters.AddWithNullableValue("@CounterId", model.CounterId);
                    command.Parameters.AddWithNullableValue("@CustomerId", model.CustomerId);
                    command.Parameters.AddWithNullableValue("@PriceTypeId", model.PriceTypeId);

                    command.Parameters.AddWithNullableValue("@ReferenceNumber", model.ReferenceNumber);
                    command.Parameters.AddWithNullableValue("@StatementReference", model.StatementReference);

                    using (var details = new SalesEntry.SqlServer().GetDetails(model.Details))
                    {
                        command.Parameters.AddWithNullableValue("@Details", details, "sales.sales_detail_type");
                    }

                    command.Parameters.AddWithNullableValue("@ShipperId", model.ShipperId);
                    command.Parameters.AddWithNullableValue("@Discount", model.Discount);

                    command.Parameters.Add("@TranId", SqlDbType.BigInt).Direction = ParameterDirection.Output;

                    connection.Open();
                    await command.ExecuteNonQueryAsync().ConfigureAwait(false);
                  
                    return command.Parameters["@TranId"].Value.To<long>();
                }
            }
        }
    }
}