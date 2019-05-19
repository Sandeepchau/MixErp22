using Frapid.Framework.Extensions;

namespace Frapid.Reports.DTO
{
    public sealed class Config
    {
        public string WkhtmltopdfExecutablePath { get; set; }

        public static Config Get()
        {
            return "~/Resources/Configs/Reports.json".PathToJson<Config>();
        }
    }
}