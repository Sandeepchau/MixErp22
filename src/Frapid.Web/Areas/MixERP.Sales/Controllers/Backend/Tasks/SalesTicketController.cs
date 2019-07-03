using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.Dashboard.Controllers;
using MixERP.Sales.Models;
using Frapid.DataAccess.Models;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    public class SalesTicketController : BackendController
    {
        [Route("dashboard/sales/ticket/{tranId}")]
        [AccessPolicy("sales", "sales_view", AccessTypeEnum.Read)]
        public async Task<ActionResult> IndexAsync(long tranId)
        {
            if (tranId <= 0)
            {
                return this.HttpNotFound(string.Format(I18N.TheTicketCouldNotBeFound, tranId));
            }

            var model = await Tickets.GetTicketViewModelAsync(this.Tenant, tranId).ConfigureAwait(true);

            if (model.View == null)
            {
                return this.HttpNotFound(string.Format(I18N.TheTicketCouldNotBeFound, tranId));
            }

            return this.View(this.GetRazorView<AreaRegistration>("Ticket/Index.cshtml", this.Tenant), model);
        }
    }
}