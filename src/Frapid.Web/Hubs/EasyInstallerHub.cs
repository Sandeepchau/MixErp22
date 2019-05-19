using Frapid.Configuration;
using Frapid.Configuration.TenantServices;
using Frapid.Installer;
using Frapid.Installer.Helpers;
using Microsoft.AspNet.SignalR;
using Serilog;
using System;
using System.Linq;

namespace Frapid.Web.Hubs
{
    public sealed class EasyInstallerHub: Hub
    {
        private string GetDomain()
        {
            string url = this.Context.Request.Url.Authority;
            var extractor = new DomainNameExtractor(Log.Logger);
            return extractor.GetDomain(url);
        }

        public void Install()
        {
            if (!this.IsValidRequest())
            {
                this.Clients.Caller.getNotification("Access is denied.");
                return;
            }

            string domain = this.GetDomain();
            var approved = new ApprovedDomainSerializer();
            var installed = new InstalledDomainSerializer();

            if (!approved.GetMemberSites().Any(x => x.Equals(domain)))
            {
                this.OnError(this, "Domain not found.");
                return;
            }
            var setup = approved.Get().FirstOrDefault(x => x.GetSubtenants().Contains(domain.ToLowerInvariant()));

            this.Do(setup);
        }

        private void Do(ApprovedDomain site)
        {
            string url = site.DomainName;
            InstallerLog.Verbose($"Installing frapid on domain {url}.");

            try
            {
                var installer = new Installer.Tenant.Installer(url, false);

                installer.Notification += delegate (object sender, string message)
                {
                    if (message.StartsWith("Error"))
                    {
                        this.OnError(sender, message);
                    }
                    else
                    {
                        this.OnNotification(sender, message);
                    }
                };

                installer.InstallAsync().GetAwaiter().GetResult();

                DbInstalledDomains.AddAsync(site).GetAwaiter().GetResult();
                new InstalledDomainSerializer().Add(site);
            }
            catch (Exception ex)
            {
                InstallerLog.Error("Could not install frapid on {url} due to errors. Exception: {Exception}", url, ex);
                throw;
            }

        }

        private void OnError(object sender, string message)
        {
            this.Clients.Caller.getEasyInstallerError(message);
        }

        private void OnNotification(object sender, string message)
        {
            this.Clients.Caller.getEasyInstallerNotification(message);
        }

        private bool IsValidRequest()
        {
            bool easyInstall = System.Configuration.ConfigurationManager.AppSettings["EasyInstall"].ToLowerInvariant() == "true";
            return easyInstall;
        }

    }
}