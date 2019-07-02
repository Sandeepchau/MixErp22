using System;
using System.Threading.Tasks;
using Frapid.Configuration.Db;
using Frapid.Mapper.Database;
using MixERP.Inventory.DAL.Backend.Setup.Variants;
using MixERP.Inventory.DTO;

namespace MixERP.Inventory.DAL.Backend.Setup
{
    public static class ItemVariants
    {
        private static IItemVariant LocateService(string tenant)
        {
            string providerName = DbProvider.GetProviderName(tenant);
            var type = DbProvider.GetDbType(providerName);

            if (type == DatabaseType.PostgreSQL)
            {
                return new PostgreSQL();
            }

            if (type == DatabaseType.SqlServer)
            {
                return new SqlServer();
            }

            throw new NotImplementedException();
        }

        public static async Task<int> CreateAsync(string tenant, ItemVariantInfo variant)
        {
            var service = LocateService(tenant);
            return await service.CreateAsync(tenant, variant).ConfigureAwait(false);
        }

        public static async Task DeleteAsync(string tenant, int itemId)
        {
            var service = LocateService(tenant);
            await service.DeleteAsync(tenant, itemId).ConfigureAwait(false);
        }
    }
}