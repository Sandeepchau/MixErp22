using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.ApplicationState.CacheFactory;
using MixERP.Inventory.DTO;

namespace MixERP.Inventory.Cache
{
    public class Setup
    {
        private const string AppDatesKey = "InventorySetup";

        private static InventorySetup FromCache(string tenant, int officeId)
        {
            var cache = new DefaultCacheFactory();
            var item = cache.Get<List<InventorySetup>>(tenant + AppDatesKey);
            return item?.FirstOrDefault(x => x.OfficeId == officeId);
        }

        private static void SetInventorySetup(string catalog, List<InventorySetup> inventorySetups)
        {
            var cache = new DefaultCacheFactory();
            cache.Add(catalog + AppDatesKey, inventorySetups, DateTimeOffset.UtcNow.AddHours(1));
        }

        public static async Task<InventorySetup> GetAsync(string tenant, int officeId)
        {
            var setup = FromCache(tenant, officeId);

            if (setup != null)
            {
                return setup;
            }

            var setups = (await DAL.Backend.Setup.InventorySetup.GetAsync(tenant).ConfigureAwait(true)).ToList();
            SetInventorySetup(tenant, setups);
            return setups.FirstOrDefault(x => x.OfficeId == officeId);
        }

        public static InventorySetup Get(string tenant, int officeId)
        {
            //Todo: uncomment these lines to enable caching again.
            //var setup = FromCache(tenant, officeId);

            //if (setup != null)
            //{
            //    return setup;
            //}

            var setups = DAL.Backend.Setup.InventorySetup.GetAsync(tenant).GetAwaiter().GetResult().ToList();
            //SetInventorySetup(tenant, setups);
            return setups.FirstOrDefault(x => x.OfficeId == officeId);
        }
    }
}