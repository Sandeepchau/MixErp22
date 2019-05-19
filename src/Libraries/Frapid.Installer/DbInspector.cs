using System;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Installer.DAL;

namespace Frapid.Installer
{
    public class DbInspector
    {
        public event EventHandler<string> Notification;

        public DbInspector(string tenant, string database)
        {
            this.Tenant = tenant;
            this.Database = database;
        }

        public string Tenant { get; }
        public string Database { get; }

        public async Task<bool> HasDbAsync()
        {
            var store = new Store();

            store.Notification += delegate(object sender, string message)
            {
                this.Notify(sender, message);
            };

            return await store.HasDbAsync(this.Tenant, this.Database).ConfigureAwait(false);
        }

        public bool IsWellKnownDb()
        {
            var serializer = new ApprovedDomainSerializer();
            var domains = serializer.Get();
            return domains.Any(domain => TenantConvention.GetTenant(domain.DomainName) == this.Tenant);
        }
        public void Notify(object sender, string message)
        {
            var notificationReceived = this.Notification;
            notificationReceived?.Invoke(sender, message);
        }
    }
}