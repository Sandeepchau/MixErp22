using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Models;
using Frapid.Installer.Helpers;

namespace Frapid.Installer.Tenant
{
    public sealed class Installer
    {
        public static List<Installable> InstalledApps;
        public event EventHandler<string> Notification;

        public Installer(string url, bool withoutSample)
        {
            this.Url = url;
            this.WithoutSample = withoutSample;
        }

        public string Url { get; set; }
        public bool WithoutSample { get; set; }

        public async Task InstallAsync()
        {
            InstalledApps = new List<Installable>();

            string tenant = TenantConvention.GetTenant(this.Url);

            this.Notify($"Creating database {tenant}.");
            var db = new DbInstaller(tenant);

            db.Notification += delegate (object sender, string message)
            {
                this.Notify(sender, message);
            };

            await db.InstallAsync().ConfigureAwait(false);

            this.Notify("Getting installables.");
            var installables = Installables.GetInstallables(tenant);

            foreach (var installable in installables)
            {
                try
                {
                    var installer = new AppInstaller(tenant, tenant, this.WithoutSample, installable);

                    installer.Notification += delegate(object sender, string message)
                    {
                        this.Notify(sender, message);
                    };

                    await installer.InstallAsync().ConfigureAwait(false);
                }
                catch (Exception ex)
                {
                    this.Notify("Error: " + ex.Message);
                    this.Notify($"Error: Could not install module {installable.ApplicationName}.");
                }
            }

            this.Notify("OK");
        }

        private void Notify(string message)
        {
            this.Notify(this, message);
        }

        private void Notify(object sender, string message)
        {
            if(message.StartsWith("Error"))
            {
                InstallerLog.Error(message);
            }
            else
            {
                InstallerLog.Verbose(message);
            }

            var notificationReceived = this.Notification;
            notificationReceived?.Invoke(sender, message);
        }
    }
}