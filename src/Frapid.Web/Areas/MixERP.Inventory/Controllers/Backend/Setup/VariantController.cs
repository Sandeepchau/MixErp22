using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class VariantController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/variants")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Variants.cshtml", this.Tenant));
        }
    }
}