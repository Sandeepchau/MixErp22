using Frapid.Configuration.Extensions;

namespace Frapid.Configuration.Models
{
    public class Parameter
    {
        public string Cultures { get; set; }
        public string ApplicationLogDirectory { get; set; }
        public string MinimumLogLevel { get; set; }
        public string BackupScheduleUTC { get; set; }
        public string DefaultCacheType { get; set; }
        public string EodScheduleUTC { get; set; }
        public bool? IsDevelopment { get; set; }

        public static Parameter Get()
        {
            return "~/Resources/Configs/Parameters.json".PathToJson<Parameter>();
        }
    }
}