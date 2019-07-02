using System.Threading.Tasks;
using Frapid.Dashboard;
using System.Web.Mvc;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class InventoryItemController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/inventory-items")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/InventoryItems.cshtml", this.Tenant));
        }

        [Route("dashboard/inventory/item/cogs/{itemId}/{unitId}/{storeId}/{quantity}")]
        public async Task<ActionResult> GetCostOfGoodSold(int itemId, int unitId, int storeId, decimal quantity)
        {
            decimal result = await DAL.Backend.Setup.Inventory.GetCogs(this.Tenant, itemId, unitId, storeId, quantity)
                .ConfigureAwait(true);
            return this.Ok(result);
        }
    }
}