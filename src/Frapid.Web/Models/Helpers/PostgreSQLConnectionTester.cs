using Frapid.Web.ViewModels;
using Npgsql;
using System;

namespace Frapid.Web.Models.Helpers
{
    internal static class PostgreSQLConnectionTester
    {
        internal static string Test(PostgreSQLConfig config)
        {
            var builder = new NpgsqlConnectionStringBuilder
            {
                Host = config.Server,
                Port = config.Port,
                Pooling = config.EnablePooling,
                MinPoolSize = config.MinPoolSize,
                MaxPoolSize = config.MaxPoolSize,
                Username = config.SuperUserId,
                Password = config.SuperUserPassword
            };


            using (var connection = new NpgsqlConnection(builder.ConnectionString))
            {
                using (var command = new NpgsqlCommand("SELECT 1;", connection))
                {
                    try
                    {
                        connection.Open();
                        command.ExecuteNonQuery();
                    }
                    catch (Exception ex)
                    {
                        return "Error: " + ex.Message;
                    }

                }
            }

            return "Connection to PostgreSQL was successful.";
        }
    }
}
