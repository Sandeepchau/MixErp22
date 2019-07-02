using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class StoreTypeController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/store-types")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/StoreTypes.cshtml", this.Tenant));
        }
    }
}