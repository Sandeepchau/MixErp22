using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Models;
using Frapid.SchemaUpdater.Tasks;
using System;

namespace Frapid.SchemaUpdater
{
    public static class Updater
    {
        private static UpdateBase GetUpdater(string tenant, Installable app)
        {
            var site = TenantConvention.GetSite(tenant);
            
            if(site == null)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("Not an approved domain.");
                Console.ForegroundColor = ConsoleColor.White;

                return null;
            }

            string providerName = site.DbProvider;

            switch (providerName)
            {
                case "Npgsql":
                    return new PostgresqlUpdater(tenant, app);
                case "System.Data.SqlClient":
                    return new SqlServerUpdater(tenant, app);
                default:
                    throw new SchemaUpdaterException("Frapid schema updater does not support provider " + providerName);
            }
        }

        public static async Task<string> UpdateAsync(string tenant, Installable app)
        {
            var updater = GetUpdater(tenant, app);
            if(updater != null)
            {
                return await updater.UpdateAsync().ConfigureAwait(false);
            }
            
            return $"Could not install updates for {app.ApplicationName} due to errors.";
        }
    }
}