using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.DataAccess.Extensions;
using Frapid.Framework.Extensions;
using MixERP.Inventory.ViewModels;

namespace MixERP.Inventory.DAL.Backend.Tasks.TransferEntry
{
    public sealed class SqlServer : ITransferEntry
    {
        public async Task<long> AddAsync(string tenant, InventoryTransfer model)
        {
            string connectionString = FrapidDbServer.GetConnectionString(tenant);
            string sql = @"EXECUTE inventory.post_transfer
                            @OfficeId, @UserId, @LoginId, @ValueDate, @BookDate, 
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
                    command.Parameters.AddWithNullableValue("@ReferenceNumber", model.ReferenceNumber);
                    command.Parameters.AddWithNullableValue("@StatementReference", model.StatementReference);

                    using (var details = this.GetDetails(model.Details))
                    {
                        command.Parameters.AddWithNullableValue("@Details", details, "inventory.transfer_type");
                    }

                    command.Parameters.Add("@TransactionMasterId", SqlDbType.BigInt).Direction = ParameterDirection.Output;

                    connection.Open();
                    await command.ExecuteNonQueryAsync().ConfigureAwait(false);

                    return command.Parameters["@TransactionMasterId"].Value.To<long>();
                }
            }
        }

        public DataTable GetDetails(IEnumerable<TransferType> details)
        {
            var table = new DataTable();
            table.Columns.Add("TransactionType", typeof(string));
            table.Columns.Add("StoreName", typeof(string));
            table.Columns.Add("ItemCode", typeof(string));
            table.Columns.Add("UnitName", typeof(string));
            table.Columns.Add("Quantity", typeof(decimal));
            table.Columns.Add("Rate", typeof(decimal));

            foreach (var detail in details)
            {
                var row = table.NewRow();

                row["TransactionType"] = detail.TransferTypeEnum.ToString();
                row["StoreName"] = detail.StoreName;
                row["ItemCode"] = detail.ItemCode;
                row["UnitName"] = detail.UnitName;
                row["Quantity"] = detail.Quantity;
                row["Rate"] = DBNull.Value;

                table.Rows.Add(row);
            }

            return table;
        }
    }
}