namespace Frapid.Web.ViewModels
{
    public class SqlServerConfig
    {
        public string Server { get; set; } = "localhost";
        public int Port { get; set; } = 0;
        public string MetaDatabase { get; set; } = "master";
        public bool EnablePooling { get; set; } = true;
        public int MinPoolSize { get; set; } = 1;
        public int MaxPoolSize { get; set; } = 100;
        public string SuperUserId { get; set; } = "sa";
        public string SuperUserPassword { get; set; }
        public bool TrustedSuperUserConnection { get; set; } = true;

        public string NetworkLibrary { get; set; } = "dbmssocn";
        public string UserId { get; set; }
        public string Password { get; set; }
        public string ReportUserId { get; set; }
        public string ReportUserPassword { get; set; }
        public string DatabaseBackupDirectory { get; set; } = "/Backups/";
    }
}