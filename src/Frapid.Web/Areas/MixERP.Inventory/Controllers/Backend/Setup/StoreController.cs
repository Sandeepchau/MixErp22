using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class StoreController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/stores")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Stores.cshtml", this.Tenant));
        }

        [Route("dashboard/inventory/store/sales")]
        public async Task<ActionResult> GetSalesStores()
        {
            var model = await DAL.Backend.Tasks.Stores.GetSalesStores(this.Tenant);
            return this.Ok(model);
        }
    }
}