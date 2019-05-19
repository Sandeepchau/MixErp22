using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Frapid.Web.ViewModels
{
    public class InstallViewModel
    {
        public string DomainName { get; set; }
        public string DbProvider { get; set; }
        public string DatabaseName { get; set; }
        public bool SkipDatabaseCreation { get; set; } = true;
        public string DefaultCacheType { get; set; } = "InProc";
        public string RedisConnectionString { get; set; } = "localhost";
        public string ApplicationUser { get; set; }
        public string ApplicationUserPassword { get; set; }
        public string ConfirmApplicationUserPassword { get; set; }

        public SqlServerConfig SqlServer { get; set; }
        public PostgreSQLConfig PostgreSQL { get; set; }
    }
}