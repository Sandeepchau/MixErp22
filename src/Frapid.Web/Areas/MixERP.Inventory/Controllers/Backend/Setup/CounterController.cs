using System.Web.Mvc;
using Frapid.Dashboard;

namespace MixERP.Inventory.Controllers.Backend.Setup
{
    public class CounterController : InventoryBackendController
    {
        [Route("dashboard/inventory/setup/counters")]
        [MenuPolicy]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/Counters.cshtml", this.Tenant));
        }
    }
}