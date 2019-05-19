using System;
using System.IO;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Framework;
using Frapid.i18n;
using Frapid.Installer.DAL;

namespace Frapid.Installer.Tenant
{
    public class Uninstaller
    {
        public event EventHandler<string> Notification;

        public Uninstaller(string url)
        {
            this.Url = url;
            this.Tenant = TenantConvention.GetTenant(this.Url);
        }

        public string Url { get; set; }
        public string Tenant { get; set; }

        public async Task UnInstallAsync()
        {
            var context = FrapidHttpContext.GetCurrent();

            if (context != null)
            {
                throw new UninstallException(Resources.DeletingWebsiteIsNotAllowed);
            }

            await this.CleanupDbAsync().ConfigureAwait(false);
            this.CleanupTenantDirectory();
            new ApprovedDomainSerializer().Remove(this.Url);
        }

        private void CleanupTenantDirectory()
        {
            string pathToTenant = PathMapper.MapPath($"/Tenants/{this.Tenant}");

            if (Directory.Exists(pathToTenant))
            {
                FileHelper.DeleteDirectoryRecursively(pathToTenant);
            }
        }

        private async Task CleanupDbAsync()
        {
            var store = new Store();
            store.Notification += delegate (object sender, string message)
            {
                this.Notify(sender, message);
            };

            await store.CleanupDbAsync(this.Tenant, this.Tenant).ConfigureAwait(false);
        }
        public void Notify(object sender, string message)
        {
            var notificationReceived = this.Notification;
            notificationReceived?.Invoke(sender, message);
        }
    }
}