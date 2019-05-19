using System.Data.Common;
using System.Data.SqlClient;
using Frapid.Configuration.DTO;
using Frapid.Mapper.Database;
using Frapid.Mapper.Types;
using MySql.Data.MySqlClient;
using Npgsql;

namespace Frapid.Configuration.Db
{

    public static class DbProvider
    {
        public static string GetProviderName(string tenant)
        {
            if (string.IsNullOrWhiteSpace(tenant))
            {
                return string.Empty;
            }

            var site = TenantConvention.GetSite(tenant);
            return site.DbProvider;
        }

        public static string GetMetaDatabase(string tenant)
        {
            if (string.IsNullOrWhiteSpace(tenant))
            {
                return string.Empty;
            }

            string provider = GetProviderName(tenant);
            string meta = string.Empty;

            if (provider.ToUpperInvariant().Equals("NPGSQL"))
            {
                var config = PostgreSQLConfig.Get();
                meta = config.MetaDatabase;

                if (string.IsNullOrWhiteSpace(meta))
                {
                    meta = "postgres";
                }
            }

            if (provider.ToUpperInvariant().Equals("SYSTEM.DATA.SQLCLIENT"))
            {
                var config = SqlServerConfig.Get();
                meta = config.MetaDatabase;

                if (string.IsNullOrWhiteSpace(meta))
                {
                    meta = "master";
                }
            }

            return meta;
        }


        public static DatabaseFactory Get(string connectionString, string tenant)
        {
            var database = GetDatabase(tenant, connectionString);
            return new DatabaseFactory(database);
        }

        public static DatabaseType GetDbType(string providerName)
        {
            switch (providerName)
            {
                case "MySql.Data":
                    return DatabaseType.MySql;
                case "Npgsql":
                    return DatabaseType.PostgreSQL;
                case "System.Data.SqlClient":
                    return DatabaseType.SqlServer;
                default:
                    throw new MapperException("Invalid provider name " + providerName);
            }
        }

        public static DbProviderFactory GetFactory(string providerName)
        {
            switch (providerName)
            {
                case "MySql.Data":
                    return MySqlClientFactory.Instance;
                case "Npgsql":
                    return NpgsqlFactory.Instance;
                case "System.Data.SqlClient":
                    return SqlClientFactory.Instance;
                default:
                    throw new MapperException("Invalid provider name " + providerName);
            }
        }


        public static MapperDb GetDatabase(string tenant, string connectionString = "")
        {
            string providerName = GetProviderName(tenant);
            var type = GetDbType(providerName);
            var provider = GetFactory(providerName);

            if (string.IsNullOrWhiteSpace(connectionString))
            {
                connectionString = FrapidDbServer.GetConnectionString(tenant);
            }

            return new MapperDb(type, provider, connectionString);
        }

        public static MapperDb GetDatabase(string tenant, string database, string connectionString)
        {
            string providerName = GetProviderName(tenant);
            var type = GetDbType(providerName);
            var provider = GetFactory(providerName);

            if (string.IsNullOrWhiteSpace(connectionString))
            {
                connectionString = FrapidDbServer.GetConnectionString(tenant, database);
            }

            return new MapperDb(type, provider, connectionString);
        }
    }
}