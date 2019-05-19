using System;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Framework.Extensions;
using Frapid.Installer.Helpers;

namespace Frapid.Installer.DAL
{
    public class Store
    {
        public event EventHandler<string> Notification;

        private static IStore GetDbServer(string tenant)
        {
            var site = TenantConvention.GetSite(tenant);
            string providerName = site.DbProvider;

            try
            {
                var iType = typeof(IStore);
                var members = iType.GetTypeMembers<IStore>();

                foreach(var member in members.Where(member => member.ProviderName.Equals(providerName)))
                {
                    return member;
                }
            }
            catch(Exception ex)
            {
                InstallerLog.Error("{Exception}", ex);
                throw;
            }

            return new PostgreSQL();
        }

        public async Task CreateDbAsync(string tenant)
        {
            var db = GetDbServer(tenant);

            db.Notification += delegate (object sender, string message)
            {
                this.Notify(sender, message);
            };

            await db.CreateDbAsync(tenant).ConfigureAwait(false);
        }

        public async Task<bool> HasDbAsync(string tenant, string dbName)
        {
            var db = GetDbServer(tenant);

            db.Notification += delegate (object sender, string message)
            {
                this.Notify(sender, message);
            };

            return await db.HasDbAsync(tenant, dbName).ConfigureAwait(false);
        }

        public async Task<bool> HasSchemaAsync(string tenant, string database, string schema)
        {
            var db = GetDbServer(tenant);

            db.Notification += delegate (object sender, string message)
            {
                this.Notify(sender, message);
            };

            return await db.HasSchemaAsync(tenant, database, schema).ConfigureAwait(false);
        }

        public async Task RunSqlAsync(string tenant, string database, string fromFile)
        {
            var db = GetDbServer(tenant);

            db.Notification += delegate (object sender, string message)
            {
                this.Notify(sender, message);
            };

            await db.RunSqlAsync(tenant, database, fromFile).ConfigureAwait(false);
        }

        public async Task CleanupDbAsync(string tenant, string database)
        {
            var db = GetDbServer(tenant);

            db.Notification += delegate (object sender, string message)
            {
                this.Notify(sender, message);
            };

            await db.CleanupDbAsync(tenant, database).ConfigureAwait(false);
        }

        public void Notify(object sender, string message)
        {
            var notificationReceived = this.Notification;
            notificationReceived?.Invoke(sender, message);
        }
    }
}