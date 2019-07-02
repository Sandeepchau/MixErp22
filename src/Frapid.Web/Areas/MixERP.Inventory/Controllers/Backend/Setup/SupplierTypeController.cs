using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class SupplierTypeController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/supplier-types")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/SupplierTypes.cshtml", this.Tenant));
        }
    }
}