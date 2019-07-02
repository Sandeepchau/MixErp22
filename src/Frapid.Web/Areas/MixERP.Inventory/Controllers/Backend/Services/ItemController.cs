using System.Threading.Tasks;
using System.Web.Mvc;

namespace MixERP.Inventory.Controllers.Backend.Services
{
    public class ItemController : InventoryBackendController
    {
        [Route("dashboard/inventory/items/cost-price/{itemId}/{unitId}")]
        public async Task<ActionResult> IndexAsync(int itemId, int unitId)
        {
            decimal price = await DAL.Backend.Service.Items.GetCostPriceAsync(this.Tenant, itemId, unitId).ConfigureAwait(true);
            return this.Ok(price);
        }

        [Route("dashboard/inventory/items/stockable")]
        public async Task<ActionResult> IndexAsync()
        {
            var model = await DAL.Backend.Service.Items.GetStockableItemsAsync(this.Tenant).ConfigureAwait(true);
            return this.Ok(model);
        }

        [Route("dashboard/inventory/items/stockable/view")]
        public async Task<ActionResult> ViewAsync()
        {
            var model = await DAL.Backend.Service.Items.GetStockableItemViewAsync(this.Tenant).ConfigureAwait(true);
            return this.Ok(model);
        }
    }
}