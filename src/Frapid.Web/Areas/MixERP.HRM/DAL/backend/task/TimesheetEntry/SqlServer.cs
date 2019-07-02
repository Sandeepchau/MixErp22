using Frapid.Configuration;
using Frapid.DataAccess.Extensions;
using Frapid.Framework.Extensions;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Web;

namespace MixERP.HRM.DAL.backend.task.TimesheetEntry
{
    public class SqlServer : ITimesheetEntry
    {
        public async Task<string> PostAsync(string tenant, ViewModels.Timesheet model)
        {
            string connectionString = FrapidDbServer.GetConnectionString(tenant);
            const string sql = @"Insert into hrm.timesheet (userID,FirstName,MiddleName,LastName)
                            values (@UserId,@FirstName,@MiddleName,@LastName)";


            using (var connection = new SqlConnection(connectionString))
            {
                using (var command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithNullableValue("@UserId", model.UserId);
                    command.Parameters.AddWithNullableValue("@FirstName", model.FirstName);
                    command.Parameters.AddWithNullableValue("@MiddleName", model.MiddleName);
                    command.Parameters.AddWithNullableValue("@LastName", model.LastName);

                    command.Parameters.Add("@TransactionMasterId", SqlDbType.BigInt).Direction = ParameterDirection.Output;
                    connection.Open();
                    await command.ExecuteNonQueryAsync().ConfigureAwait(false);
                    return "S";
                   // return command.Parameters["@TransactionMasterId"].Value.To<long>();
                }
            }
        }
    }
}