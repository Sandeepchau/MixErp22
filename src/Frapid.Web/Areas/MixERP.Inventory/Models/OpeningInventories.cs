using System.Threading.Tasks;
using Frapid.ApplicationState.Models;
using MixERP.Inventory.ViewModels;

namespace MixERP.Inventory.Models
{
    public static class OpeningInventories
    {
        public static async Task<OpeningInventoryViewModel> GetModelAsync(string tenant, LoginView meta)
        {
            var status = await DAL.Backend.Setup.Inventory.GetOpeningStatusAsync(tenant, meta.OfficeId).ConfigureAwait(false);

            return new OpeningInventoryViewModel
            {
                OfficeId = meta.OfficeId,
                OfficeCode = meta.OfficeCode,
                OfficeName = meta.OfficeName,
                MultipleInventoryAllowed = status.MultipleInventoryAllowed,
                HasOpeningInventory = status.HasOpeningInventory
            };
        }
    }
}