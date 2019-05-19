using Frapid.Framework;
using Newtonsoft.Json;
using System;
using System.IO;
using System.Text;

namespace Frapid.Configuration.Extensions
{
    public static class JsonExtension
    {
        public static T PathToJson<T>(this string path, bool mapPath = true)
        {
            if(mapPath)
            {
                path = PathMapper.MapPath(path);
            }

            if (File.Exists(path))
            {
                string contents = File.ReadAllText(path, new UTF8Encoding(false));
                var config = JsonConvert.DeserializeObject<T>(contents, JsonHelper.GetJsonSerializerSettings());
                return config;
            }

            return (T)Activator.CreateInstance(typeof(T));
        }
    }
}
