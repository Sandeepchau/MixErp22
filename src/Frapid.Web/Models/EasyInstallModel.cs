using Frapid.Web.ViewModels;
using System.Collections.Generic;
using Frapid.Web.Models.Helpers;

namespace Frapid.Web.Models
{
    public static class EasyInstallModel
    {
        public static string WriteConfig()
        {
            var model = EasyInstallConfigFile.Get();
            return ConfigWriter.WriteConfig(model);
        }

        public static List<string> TestPermission()
        {
            var directoriesToTest = new[] { "/Resource/", "/Resources", "/Tenants", "/Backups" };
            return FilePermissionHelper.TestPermission(directoriesToTest);
        }
        public static string TestPostgreSQL()
        {
            var model = EasyInstallConfigFile.Get();

            return PostgreSQLConnectionTester.Test(model.PostgreSQL);
        }
        public static string TestSqlServer()
        {
            var model = EasyInstallConfigFile.Get();
            return SqlServerConnectionTester.Test(model.SqlServer);
        }

        public static string TestRedis()
        {
            var model = EasyInstallConfigFile.Get();
            return RedisConnectionTester.Test(model.RedisConnectionString);
        }

        public static void Save(InstallViewModel model)
        {
            EasyInstallConfigFile.Save(model);
        }
    }

}