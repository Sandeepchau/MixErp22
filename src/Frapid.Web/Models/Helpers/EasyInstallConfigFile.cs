using Frapid.Web.ViewModels;
using Newtonsoft.Json;
using System.IO;
using System.Text;
using System.Web.Hosting;

namespace Frapid.Web.Models.Helpers
{
    internal static class EasyInstallConfigFile
    {
        private static string path = HostingEnvironment.MapPath("~/Resource/Temp/EasyInstall.json");
        internal static InstallViewModel Get()
        {
            if (!File.Exists(path))
            {
                return null;
            }

            string contents = File.ReadAllText(path, new UTF8Encoding(false));
            return JsonConvert.DeserializeObject<InstallViewModel>(contents);
        }

        internal static void Save(InstallViewModel model)
        {
            string contents = JsonConvert.SerializeObject(model, Formatting.Indented);
            File.WriteAllText(path, contents, new UTF8Encoding(false));
        }
    }
}
