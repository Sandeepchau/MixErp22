using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class BrandController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/brands")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Brands.cshtml", this.Tenant));
        }
    }
}