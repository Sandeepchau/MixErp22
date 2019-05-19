using Frapid.Web.ViewModels;
using System;
using System.Data.SqlClient;

namespace Frapid.Web.Models.Helpers
{
    internal static class SqlServerConnectionTester
    {
        internal static string Test(SqlServerConfig config)
        {
            var builder = new SqlConnectionStringBuilder
            {
                DataSource = config.Server,
                NetworkLibrary = config.NetworkLibrary,
                Pooling = config.EnablePooling,
                MinPoolSize = config.MinPoolSize,
                MaxPoolSize = config.MaxPoolSize
            };

            if (config.TrustedSuperUserConnection)
            {
                builder.IntegratedSecurity = true;
            }
            else
            {
                builder.UserID = config.SuperUserId;
                builder.Password = config.SuperUserPassword;
            }


            using (var connection = new SqlConnection(builder.ConnectionString))
            {
                using (var command = new SqlCommand("SELECT 1;", connection))
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

            return "Connection to SQL Server was successful.";
        }

    }
}
