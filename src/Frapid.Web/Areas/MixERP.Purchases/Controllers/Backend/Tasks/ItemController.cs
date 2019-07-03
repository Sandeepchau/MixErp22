using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using MixERP.Purchases.DAL.Backend.Service;
using Frapid.DataAccess.Models;
using Frapid.Dashboard;

namespace MixERP.Purchases.Controllers.Backend.Tasks
{
    public class ItemController : PurchaseDashboardController
    {
        [Route("dashboard/purchase/tasks/items")]
        [AccessPolicy("purchase", "item_view", AccessTypeEnum.Read)]
        public async Task<ActionResult> IndexAsync()
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            var model = await Items.GetItemsAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);
            return this.Ok(model);
        }

        [Route("dashboard/purchase/tasks/cost-price/{itemId}/{supplierId}/{unitId}")]
        public async Task<ActionResult> CostPriceAsync(int itemId, int supplierId, int unitId)
        {
            if (itemId < 0 || unitId < 0)
            {
                return this.InvalidModelState(this.ModelState);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            decimal model = await Items.GetCostPriceAsync(this.Tenant, meta.OfficeId, itemId, supplierId, unitId).ConfigureAwait(true);
            return this.Ok(model);
        }
    }
}