using System;
using System.Globalization;
using System.IO;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.Configuration.Models;
using Frapid.DataAccess;
using Frapid.Framework;
using Frapid.Installer.DAL;
using Frapid.Installer.Tenant;

namespace Frapid.Installer
{
    public class AppInstaller
    {
        public event EventHandler<string> Notification;

        public AppInstaller(string tenant, string database, bool withoutSample, Installable installable)
        {
            this.Tenant = tenant;
            this.Database = database;
            this.WithoutSample = withoutSample;
            this.Installable = installable;
        }

        public Installable Installable { get; }
        protected string Tenant { get; set; }
        protected string Database { get; set; }
        protected bool WithoutSample { get; set; }

        public async Task<bool> HasSchemaAsync(string database)
        {
            var store = new Store();

            store.Notification += delegate (object sender, string message)
            {
                this.Notify(sender, message);
            };

            return await store.HasSchemaAsync(this.Tenant, database, this.Installable.DbSchema).ConfigureAwait(false);
        }

        public async Task InstallAsync()
        {
            if (Installer.Tenant.Installer.InstalledApps.Contains(this.Installable))
            {
                return;
            }

            foreach (var dependency in this.Installable.Dependencies)
            {
                await new AppInstaller(this.Tenant, this.Database, this.WithoutSample, dependency).InstallAsync().ConfigureAwait(false);
            }

            this.Notify($"Installing module {this.Installable.ApplicationName}.");

            await this.CreateSchemaAsync().ConfigureAwait(false);
            await this.CreateMyAsync().ConfigureAwait(false);
            this.CreateOverride();
            Installer.Tenant.Installer.InstalledApps.Add(this.Installable);

            if (this.Installable.ApplicationName == "Frapid.Account")
            {
                var domain = TenantConvention.FindDomainByTenant(this.Tenant);
                await UserInstaller.CreateUserAsync(this.Tenant, domain).ConfigureAwait(false);
            }
        }

        protected async Task CreateMyAsync()
        {
            if (string.IsNullOrWhiteSpace(this.Installable.My))
            {
                return;
            }

            string database = this.Database;
            if (this.Installable.IsMeta)
            {
                database = Factory.GetMetaDatabase(database);
            }

            string db = this.Installable.My;
            string path = PathMapper.MapPath(db);
            await this.RunSqlAsync(database, database, path).ConfigureAwait(false);
        }

        protected async Task CreateSchemaAsync()
        {
            string database = this.Database;

            if (this.Installable.IsMeta)
            {
                this.Notify($"Creating database of {this.Installable.ApplicationName} under meta database {Factory.GetMetaDatabase(this.Database)}.");
                database = Factory.GetMetaDatabase(this.Database);
            }

            if (string.IsNullOrWhiteSpace(this.Installable.DbSchema))
            {
                return;
            }


            if (await this.HasSchemaAsync(database).ConfigureAwait(false))
            {
                this.Notify($"Skipped {this.Installable.ApplicationName} schema ({this.Installable.DbSchema}) creation because it already exists.");
                return;
            }

            this.Notify($"Creating schema {this.Installable.DbSchema}");


            string db = this.Installable.BlankDbPath;
            string path = PathMapper.MapPath(db);
            await this.RunSqlAsync(this.Tenant, database, path).ConfigureAwait(false);


            if (this.Installable.InstallSample && !string.IsNullOrWhiteSpace(this.Installable.SampleDbPath))
            {
                //Manually override sample data installation
                if (!this.WithoutSample)
                {
                    this.Notify($"Creating sample data of {this.Installable.ApplicationName}.");
                    db = this.Installable.SampleDbPath;
                    path = PathMapper.MapPath(db);
                    await this.RunSqlAsync(database, database, path).ConfigureAwait(false);
                }
            }
        }

        private async Task RunSqlAsync(string tenant, string database, string fromFile)
        {
            try
            {
                var store = new Store();
                store.Notification += delegate (object sender, string message)
                {
                    this.Notify(sender, message);
                };

                await store.RunSqlAsync(tenant, database, fromFile).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                this.Notify($"Error: {ex.Message}");
                throw;
            }
        }


        protected void CreateOverride()
        {
            if (string.IsNullOrWhiteSpace(this.Installable.OverrideTemplatePath) ||
                string.IsNullOrWhiteSpace(this.Installable.OverrideDestination))
            {
                return;
            }

            string providerName = DbProvider.GetProviderName(this.Tenant);

            if (!string.IsNullOrWhiteSpace(this.Installable.OverrideTenantProviderType) && !this.Installable.OverrideTenantProviderType.ToUpperInvariant().Trim().Equals(providerName.ToUpperInvariant().Trim()))
            {
                return;
            }

            string source = PathMapper.MapPath(this.Installable.OverrideTemplatePath);
            string destination = string.Format(CultureInfo.InvariantCulture, this.Installable.OverrideDestination,
                this.Database);
            destination = PathMapper.MapPath(destination);


            if (string.IsNullOrWhiteSpace(source) ||
                string.IsNullOrWhiteSpace(destination))
            {
                return;
            }

            if (!Directory.Exists(source))
            {
                return;
            }

            this.Notify($"Creating overide. Source: {source}, desitation: {destination}.");
            FileHelper.CopyDirectory(source, destination);
        }

        private void Notify(string message)
        {
            this.Notify(this, message);
        }

        private void Notify(object sender, string message)
        {
            var notificationReceived = this.Notification;
            notificationReceived?.Invoke(this, message);
        }
    }
}