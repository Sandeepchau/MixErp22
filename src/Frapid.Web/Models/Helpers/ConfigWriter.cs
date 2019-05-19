using Frapid.Web.ViewModels;
using Microsoft.VisualBasic.FileIO;
using Newtonsoft.Json;
using System.IO;
using System.Text;
using System.Web.Hosting;

namespace Frapid.Web.Models.Helpers
{
    internal static class ConfigWriter
    {
        private static void WriteFile(object item, string path)
        {
            string contents = JsonConvert.SerializeObject(item, Formatting.Indented);
            File.WriteAllText(HostingEnvironment.MapPath(path), contents, new UTF8Encoding(false));
        }


        internal static string WriteConfig(InstallViewModel model)
        {
            string pathToConfigTemplateDirectory = HostingEnvironment.MapPath("~/Resources/_Configs");
            string pathToConfigDirectory = HostingEnvironment.MapPath("~/Resources/Configs");


            if (!Directory.Exists(pathToConfigDirectory))
            {
                FileSystem.CopyDirectory(pathToConfigTemplateDirectory, pathToConfigDirectory);
            }

            WriteFile(model.SqlServer, "~/Resources/Configs/SQLServer.json");
            WriteFile(model.PostgreSQL, "~/Resources/Configs/PostgreSQL.json");

            WriteFile(new[]
            {
                new
                {
                    model.DbProvider,
                    model.DomainName,
                    model.DatabaseName,
                    EnforceSsl = false,
                    CdnDomain = "",
                    Synonyms = new string[] { },
                    BackupDirectory = "",
                    BackupDirectoryIsFixedPath = false,
                    AdminEmail = model.ApplicationUser,
                    BcryptedAdminPassword = PasswordManager.GetHashedPassword(model.ApplicationUser, model.ApplicationUserPassword)
                }
            }, "~/Resources/Configs/DomainsApproved.json");

            WriteFile(new
            {
                Cultures = "en",
                ApplicationLogDirectory = @"C:\frapid-logs",
                MinimumLogLevel = "Information",
                BackupScheduleUTC = "0, 15",
                EodScheduleUTC = "0, 5",
                model.DefaultCacheType,
                IsDevelopment = true
            }, "~/Resources/Configs/Parameters.json");

            WriteFile(new
            {
                ConfigString = model.RedisConnectionString
            }, "~/Resources/Configs/RedisConfig.json");

            return "OK";
        }

    }
}
