using Frapid.Configuration.Db;
using Frapid.Configuration.DTO;

namespace Frapid.Backups
{
    public sealed class DbServer
    {
        public DbServer(string tenant)
        {
            this.Tenant = tenant;

            string provider = DbProvider.GetProviderName(tenant);

            if (provider.ToUpperInvariant().Equals("NPGSQL"))
            {
                var config = PostgreSQLConfig.Get();

                this.ProviderName = provider;
                this.BinDirectory = config.PostgreSQLBinDirectory;
                this.DatabaseBackupDirectory = config.DatabaseBackupDirectory;
                this.HostName = config.Server;
                this.PortNumber = config.Port ?? 5432;
                this.UserId = config.UserId;
                this.Password = config.Password;
            }

            if (provider.ToUpperInvariant().Equals("SYSTEM.DATA.SQLCLIENT"))
            {
                var config = SqlServerConfig.Get();

                this.ProviderName = provider;
                this.DatabaseBackupDirectory = config.DatabaseBackupDirectory;
                this.HostName = config.Server;
                this.PortNumber = config.Port ?? 0;
                this.UserId = config.UserId;
                this.Password = config.Password;
            }


            this.Validate();
        }

        public string Tenant { get; set; }
        public string ProviderName { get; set; }
        public string BinDirectory { get; set; }
        public string DatabaseBackupDirectory { get; set; }
        public string HostName { get; set; }
        public bool IsValid { get; private set; }
        public string Password { get; set; }
        public int PortNumber { get; set; }
        public string UserId { get; set; }

        public void Validate()
        {
            this.IsValid = true;

            if(string.IsNullOrWhiteSpace(this.HostName))
            {
                this.IsValid = false;
                return;
            }

            if(string.IsNullOrWhiteSpace(this.UserId))
            {
                this.IsValid = false;
                return;
            }

            if(string.IsNullOrWhiteSpace(this.Password))
            {
                this.IsValid = false;
                return;
            }

            if(this.PortNumber <= 0)
            {
                this.IsValid = false;
            }
        }
    }
}