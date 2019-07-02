using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.DataAccess.Extensions;
using Frapid.Framework.Extensions;
using MixERP.Inventory.ViewModels;

namespace MixERP.Inventory.DAL.Backend.Setup.OpeningEntry
{
    public sealed class SqlServer : IOpeningEntry
    {
        public async Task<long> PostAsync(string tenant, OpeningInventory model)
        {
            string connectionString = FrapidDbServer.GetConnectionString(tenant);

            string sql = @"EXECUTE inventory.post_opening_inventory
                                @OfficeId, @UserId, @LoginId, 
                                @ValueDate, @BookDate, 
                                @ReferenceNumber, @StatementReference, 
                                @Details, @TransactionMasterId OUTPUT
                            ;";


            using (var connection = new SqlConnection(connectionString))
            {
                using (var command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithNullableValue("@OfficeId", model.OfficeId);
                    command.Parameters.AddWithNullableValue("@UserId", model.UserId);
                    command.Parameters.AddWithNullableValue("@LoginId", model.LoginId);
                    command.Parameters.AddWithNullableValue("@ValueDate", model.ValueDate);
                    command.Parameters.AddWithNullableValue("@BookDate", model.BookDate);
                    command.Parameters.AddWithNullableValue("@ReferenceNumber", model.ReferenceNumber.Or(""));
                    command.Parameters.AddWithNullableValue("@StatementReference", model.StatementReference.Or(""));

                    using (var details = this.GetDetails(model.Details))
                    {
                        command.Parameters.AddWithNullableValue("@Details", details, "inventory.opening_stock_type");
                    }

                    command.Parameters.Add("@TransactionMasterId", SqlDbType.BigInt).Direction = ParameterDirection.Output;

                    connection.Open();
                    await command.ExecuteNonQueryAsync().ConfigureAwait(false);
                    return command.Parameters["@TransactionMasterId"].Value.To<long>();
                }
            }
        }

        public DataTable GetDetails(IEnumerable<OpeningStockType> details)
        {
            var table = new DataTable();
            table.Columns.Add("StoreId", typeof(int));
            table.Columns.Add("ItemId", typeof(int));
            table.Columns.Add("Quantity", typeof(decimal));
            table.Columns.Add("UnitId", typeof(int));
            table.Columns.Add("Price", typeof(decimal));

            foreach (var detail in details)
            {
                var row = table.NewRow();
                row["StoreId"] = detail.StoreId;
                row["ItemId"] = detail.ItemId;
                row["Quantity"] = detail.Quantity;
                row["UnitId"] = detail.UnitId;
                row["Price"] = detail.Price;

                table.Rows.Add(row);
            }

            return table;
        }


    }
}