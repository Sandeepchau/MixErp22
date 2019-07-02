using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class CustomerTypeController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/customer-types")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/CustomerTypes.cshtml", this.Tenant));
        }
    }
}