using System.Collections.Generic;
using System.IO;
using System.Web.Hosting;

namespace Frapid.Web.Models.Helpers
{
    internal static class FilePermissionHelper
    {
        private static bool IsDirectoryWritable(string dirPath, bool throwIfFails = false)
        {
            try
            {
                using (FileStream fs = File.Create(
                    Path.Combine(
                        dirPath,
                        Path.GetRandomFileName()
                    ),
                    1,
                    FileOptions.DeleteOnClose)
                )
                { }
                return true;
            }
            catch
            {
                if (throwIfFails)
                    throw;
                else
                    return false;
            }
        }

        internal static List<string> TestPermission(string[] directoriesToTest)
        {
            var result = new List<string>();

            foreach (var directoryToTest in directoriesToTest)
            {
                string directory = HostingEnvironment.MapPath(directoryToTest);
                bool hasPermission = IsDirectoryWritable(directory);

                if (hasPermission)
                {
                    result.Add($"OK: Directory {directoryToTest} is writable");
                }
                else
                {
                    result.Add($"Error: Can't write to the directory {directoryToTest}");
                }
            }

            return result;
        }
    }
}
