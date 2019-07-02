using System.Threading.Tasks;
using MixERP.Inventory.ViewModels;

namespace MixERP.Inventory.DAL.Backend.Tasks.AdjustmentEntry
{
    public interface IAdjustmentEntry
    {
        Task<long> AddAsync(string tenant, InventoryAdjustment model);
    }
}