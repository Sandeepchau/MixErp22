using System.Threading.Tasks;
using MixERP.Inventory.ViewModels;

namespace MixERP.Inventory.DAL.Backend.Setup.OpeningEntry
{
    public interface IOpeningEntry
    {
        Task<long> PostAsync(string tenant, OpeningInventory model);
    }
}