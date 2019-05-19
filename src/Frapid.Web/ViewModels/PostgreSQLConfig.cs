namespace Frapid.Web.ViewModels
{
    public class PostgreSQLConfig
    {
        public string Server { get; set; }
        public int Port { get; set; } = 5432;
        public string MetaDatabase { get; set; } = "postgres";
        public bool EnablePooling { get; set; } = true;
        public int MinPoolSize { get; set; } = 1;
        public int MaxPoolSize { get; set; } = 100;
        public string SuperUserId { get; set; } = "postgres";
        public string SuperUserPassword { get; set; }
        public bool TrustedSuperUserConnection { get; set; }
        public string UserId { get; set; }
        public string Password { get; set; }
        public string ReportUserId { get; set; }
        public string ReportUserPassword { get; set; }
        public  string PostgreSQLBinDirectory { get; set; }
        public string DatabaseBackupDirectory { get; set; } = "/Backups/";
    }
}