using System.Data.SqlClient;
using Frapid.Configuration.DTO;
using Frapid.Framework.Extensions;

namespace Frapid.Configuration.DbServer
{
    public class SqlServer : IDbServer
    {
        public string GetConnectionString(string tenant, string database = "", string userId = "", string password = "")
        {
            var config = SqlServerConfig.Get();

            if (string.IsNullOrWhiteSpace(userId))
            {
                userId = config.UserId;
            }

            if (string.IsNullOrWhiteSpace(password))
            {
                password = config.Password;
            }


            return this.GetConnectionString(tenant, config.Server, database, userId, password, config.Port ?? 0, config.EnablePooling ?? true, config.MinPoolSize ?? 1, config.MaxPoolSize ?? 100, config.NetworkLibrary);
        }

        public string GetReportUserConnectionString(string tenant, string database = "")
        {
            var config = SqlServerConfig.Get();
            return this.GetConnectionString(tenant, database, config.ReportUserId, config.ReportUserPassword);
        }

        public string ProviderName => "System.Data.SqlClient";

        public string GetSuperUserConnectionString(string tenant, string database = "")
        {
            var config = SqlServerConfig.Get();

            string dataSource = config.Server;

            if (config.Port > 0)
            {
                dataSource += ", " + config.Port;
            }

            var builder = new SqlConnectionStringBuilder
            {
                DataSource = dataSource,
                InitialCatalog = database,
                Pooling = config.EnablePooling ?? true,
                MinPoolSize = config.MinPoolSize ?? 1,
                MaxPoolSize = config.MaxPoolSize ?? 100,
                //ApplicationName = "Frapid",
                //NetworkLibrary = config.NetworkLibrary,
                ConnectTimeout = config.Timeout ?? 120
            };

            if (config.TrustedSuperUserConnection.To(false))
            {
                builder.IntegratedSecurity = true;
            }
            else
            {
                builder.UserID = config.SuperUserId;
                builder.Password = config.SuperUserPassword;
            }

            return builder.ConnectionString;
        }

        public string GetMetaConnectionString(string tenant)
        {
            var config = SqlServerConfig.Get();

            return this.GetConnectionString(tenant, config.MetaDatabase);
        }

        public string GetConnectionString(string tenant, string host, string database, string username, string password, int port, bool enablePooling = true, int minPoolSize = 0, int maxPoolSize = 100, string networkLibrary = "")
        {
            string dataSource = host;

            if (port > 0)
            {
                dataSource += ", " + port;
            }

            /**********************************************************************************************************
                NetworkLibrary
                ---------------
                dbnmpntw	Named Pipes
                dbmslpcn	Shared Memory (localhost)
                dbmssocn	TCP/IP
                dbmsspxn	SPX/IPX
                dbmsvinn	Banyan Vines
                dbmsrpcn	Multi-Protocol (Windows RPC)
                dbmsadsn	Apple Talk
                dbmsgnet	VIA
            **********************************************************************************************************/

            return new SqlConnectionStringBuilder
            {
                DataSource = dataSource,
                InitialCatalog = database,
                UserID = username,
                Password = password,
                Pooling = enablePooling,
                MinPoolSize = minPoolSize,
                MaxPoolSize = maxPoolSize,
                //ApplicationName = "Frapid",
                //NetworkLibrary = networkLibrary.Or("dbmssocn")
            }.ConnectionString;
        }

        public string GetProcedureCommand(string procedureName, string[] parameters)
        {
            string sql = $"; EXECUTE {procedureName} {string.Join(", ", parameters)};";
            return sql;
        }

        public string DefaultSchemaQualify(string input)
        {
            return "[dbo]." + input;
        }

        public string AddLimit(string limit)
        {
            return $" FETCH NEXT {limit} ROWS ONLY";
        }

        public string AddOffset(string offset)
        {
            return $" OFFSET {offset} ROWS";
        }

        public string AddReturnInsertedKey(string primaryKeyName)
        {
            return "; SELECT SCOPE_IDENTITY();";
        }

        public string GetDbTimestampFunction()
        {
            return "getutcdate()";
        }
    }
}
 