using System.Threading.Tasks;
using MixERP.Inventory.ViewModels;

namespace MixERP.Inventory.DAL.Backend.Tasks.TransferEntry
{
    public interface ITransferEntry
    {
        Task<long> AddAsync(string tenant, InventoryTransfer model);
    }
}