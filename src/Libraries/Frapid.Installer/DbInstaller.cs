using System;
using System.Threading.Tasks;
using Frapid.Configuration.Db;
using Frapid.Configuration.Models;
using Frapid.Framework.Extensions;
using Frapid.Installer.DAL;

namespace Frapid.Installer
{
    public sealed class DbInstaller
    {
        public event EventHandler<string> Notification;

        public DbInstaller(string domain)
        {
            this.Tenant = domain;
        }

        public string Tenant { get; }

        private static bool IsDevelopment()
        {
            var parameters = Parameter.Get();
            return parameters.IsDevelopment.To(false);
        }


        public async Task<bool> InstallAsync()
        {
            string meta = DbProvider.GetMetaDatabase(this.Tenant);
            var inspector = new DbInspector(this.Tenant, meta);
            bool hasDb = await inspector.HasDbAsync().ConfigureAwait(false);
            bool isWellKnown = inspector.IsWellKnownDb();

            if (hasDb)
            {
                if (IsDevelopment())
                {
                    this.Notify(this, "Cleaning up the database.");
                    await this.CleanUpDbAsync().ConfigureAwait(true);
                }
                else
                {
                    this.Notify(this, "Warning: database already exists. Please remove the database first.");
                    this.Notify(this, $"No need to create database \"{this.Tenant}\" because it already exists.");
                }
            }

            if (!isWellKnown)
            {
                this.Notify(this, $"Cannot create a database under the name \"{this.Tenant}\" because the name is not a well-known tenant name.");
            }

            if (!hasDb && isWellKnown)
            {
                this.Notify(this, $"Creating database \"{this.Tenant}\".");
                await this.CreateDbAsync().ConfigureAwait(false);
                return true;
            }

            return false;
        }

        private async Task CreateDbAsync()
        {
            var store = new Store();
            store.Notification += delegate (object sender, string message)
            {
                this.Notify(sender, message);
            };

            await store.CreateDbAsync(this.Tenant).ConfigureAwait(false);
        }

        private async Task CleanUpDbAsync()
        {
            var store = new Store();
            store.Notification += delegate (object sender, string message)
            {
                this.Notify(sender, message);
            };

            await store.CleanupDbAsync(this.Tenant, this.Tenant).ConfigureAwait(false);
        }

        private void Notify(object sender, string message)
        {
            var notificationReceived = this.Notification;
            notificationReceived?.Invoke(sender, message);
        }
    }
}