using Frapid.Configuration;
using Frapid.Framework.Extensions;
using Npgsql;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;

namespace MixERP.HRM.DAL.backend.task.TimesheetEntry
{
    public class PostgreSQL : ITimesheetEntry
    {
        public async Task<string> PostAsync(string tenant, ViewModels.Timesheet model)
        {
            string connectionString = FrapidDbServer.GetConnectionString(tenant);
            string sql = @"";
           

            using (var connection = new NpgsqlConnection(connectionString))
            {
                using (var command = new NpgsqlCommand(sql, connection))
                {
                    //command.Parameters.AddWithNullableValue("@OfficeId", model.OfficeId);
                    //command.Parameters.AddWithNullableValue("@UserId", model.UserId);
                    //command.Parameters.AddWithNullableValue("@LoginId", model.LoginId);
                    //command.Parameters.AddWithNullableValue("@CounterId", model.CounterId);                 
                    

                    connection.Open();
                    var awaiter = await command.ExecuteScalarAsync().ConfigureAwait(false);
                    return awaiter.To<string>();
                }
            }
        }
    }
}