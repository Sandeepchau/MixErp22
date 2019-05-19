using Frapid.Configuration.Extensions;

namespace Frapid.Configuration.DTO
{

    public sealed class PostgreSQLConfig
    {
        public string Server { get; set; }
        public int? Port { get; set; } = 5432;
        public string MetaDatabase { get; set; }
        public bool? EnablePooling { get; set; } = true;
        public int? MinPoolSize { get; set; } = 1;
        public int? MaxPoolSize { get; set; } = 100;
        public string SuperUserId { get; set; }
        public string SuperUserPassword { get; set; }
        public bool? TrustedSuperUserConnection { get; set; } = false;
        public string UserId { get; set; }
        public string Password { get; set; }
        public string ReportUserId { get; set; }
        public string ReportUserPassword { get; set; }
        public string PostgreSQLBinDirectory { get; set; }
        public string DatabaseBackupDirectory { get; set; }
        public int? Timeout { get; set; } = 120;
        public static PostgreSQLConfig Get()
        {
            return "~/Resources/Configs/PostgreSQL.json".PathToJson<PostgreSQLConfig>();
        }
    }
}
