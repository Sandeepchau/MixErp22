using System;
using System.Data.Common;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using Frapid.Configuration.Db;
using Frapid.Framework.Extensions;
using Frapid.Mapper.Database;
using Npgsql;

namespace Frapid.DataAccess
{
    public static class DbErrorParser
    {
        public static string GetException(string database, string message, Exception exception)
        {
            if (!(exception is DbException ex))
            {
                return message;
            }          

            string identifier = string.Empty;
            DatabaseType dbType;

            using (var db = DbProvider.GetDatabase(database))
            {
               dbType = db.DatabaseType;

                switch (dbType)
                {
                    case DatabaseType.PostgreSQL:
                        identifier = GetPostgreSQLErrorCode(ex);
                        break;
                    case DatabaseType.SqlServer:
                        identifier = GetSqlServerErrorCode(ex);
                        break;
                }
            }

            if (string.IsNullOrWhiteSpace(identifier))
            {
                return message;
            }

            var type = typeof(IDbErrorMessage);
            var members = type.GetTypeMembersNotAbstract<IDbErrorMessage>();

            foreach (var candidate in members.Where(x => x.DatabaseType == dbType && x.Identifiers.Contains(identifier)))
            {
                return candidate.Parse(ex);
            }

            return message;
        }

        private static string GetPostgreSQLErrorCode(DbException ex)
        {
            if (!(ex is PostgresException inner))
            {
                return string.Empty;
            }

            string identifier = inner.SqlState;
            return identifier;
        }

        private static string GetSqlServerErrorCode(DbException ex)
        {
            if (!(ex is SqlException inner))
            {
                return string.Empty;
            }

            //SELECT * FROM sys.sysmessages
            //will return all error numbers
            return inner.Number.ToString(CultureInfo.InvariantCulture);
        }
    }
}