using Frapid.Configuration.Db;
using Frapid.Configuration.DTO;
using Frapid.Mapper.Extensions;
using Npgsql;

namespace Frapid.Configuration.DbServer
{
    public class PostgreSQL : IDbServer
    {

        public string GetConnectionString(string tenant, string database = "", string userId = "", string password = "")
        {
            var config = PostgreSQLConfig.Get();

            if (string.IsNullOrWhiteSpace(userId))
            {
                userId = config.UserId;
            }

            if (string.IsNullOrWhiteSpace(password))
            {
                password = config.Password;
            }


            return this.GetConnectionString(tenant, config.Server, database, userId, password, config.Port ?? 5432, config.EnablePooling ?? true, config.MinPoolSize ?? 1, config.MaxPoolSize ?? 100);
        }

        public string GetReportUserConnectionString(string tenant, string database = "")
        {
            var config = PostgreSQLConfig.Get();
            return this.GetConnectionString(tenant, database, config.ReportUserId, config.ReportUserPassword);
        }

        public string ProviderName => "Npgsql";

        public string GetSuperUserConnectionString(string tenant, string database = "")
        {
            var config = PostgreSQLConfig.Get();

            var builder = new NpgsqlConnectionStringBuilder
            {
                Host = config.Server,
                Port = config.Port ?? 5432,
                Database = database,
                Pooling = config.EnablePooling ?? true,
                MinPoolSize = config.MinPoolSize ?? 1,
                MaxPoolSize = config.MaxPoolSize ?? 100,
                ApplicationName = "Frapid",
                CommandTimeout = config.Timeout ?? 120,
                InternalCommandTimeout = config.Timeout ?? 120
            };

            if (config.TrustedSuperUserConnection.To(false))
            {
                builder.IntegratedSecurity = true;
            }
            else
            {
                builder.Username = config.SuperUserId;
                builder.Password = config.SuperUserPassword;
            }

            return builder.ConnectionString;
        }

        public string GetMetaConnectionString(string tenant)
        {
            var config = PostgreSQLConfig.Get();
            return this.GetConnectionString(tenant, config.MetaDatabase);
        }

        public string GetConnectionString(string tenant, string host, string database, string username, string password, int port, bool enablePooling = true, int minPoolSize = 0, int maxPoolSize = 100, string networkLibrary = "")
        {
            return new NpgsqlConnectionStringBuilder
            {
                Host = host,
                Database = database,
                Username = username,
                Password = password,
                Port = port,
                Pooling = enablePooling,
                UseSslStream = true,
                SslMode = SslMode.Prefer,
                MinPoolSize = minPoolSize,
                MaxPoolSize = maxPoolSize,
                ApplicationName = "Frapid"
            }.ConnectionString;
        }

        public string GetProcedureCommand(string procedureName, string[] parameters)
        {
            string sql = $"SELECT * FROM {procedureName}({string.Join(", ", parameters)});";
            return sql;
        }

        public string DefaultSchemaQualify(string input)
        {
            return "public." + input;
        }

        public string AddLimit(string limit)
        {
            return $" LIMIT {limit}";
        }

        public string AddOffset(string offset)
        {
            return $" OFFSET {offset}";
        }

        public string AddReturnInsertedKey(string primaryKeyName)
        {
            return $"RETURNING {Sanitizer.SanitizeIdentifierName(primaryKeyName)}";
        }

        public string GetDbTimestampFunction()
        {
            return "NOW()";
        }
    }
}