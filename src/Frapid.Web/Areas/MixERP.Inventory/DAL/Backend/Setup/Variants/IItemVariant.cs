using System.Threading.Tasks;
using MixERP.Inventory.DTO;

namespace MixERP.Inventory.DAL.Backend.Setup.Variants
{
    public interface IItemVariant
    {
        Task<int> CreateAsync(string tenant, ItemVariantInfo variant);
        Task DeleteAsync(string tenant, int itemId);
    }
}