using Frapid.Configuration.Models;
using Frapid.Framework.Extensions;

namespace Frapid.Configuration
{
    public static class CacheConfig
    {
        public static string GetDefaultCacheType()
        {
            var parameter = Parameter.Get();
            return parameter.DefaultCacheType.Or("InProc");
        }
    }
}