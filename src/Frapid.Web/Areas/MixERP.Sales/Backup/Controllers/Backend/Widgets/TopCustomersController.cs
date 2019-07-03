using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using System.Web.UI;
using Frapid.ApplicationState.Cache;
using Frapid.Areas.Caching;
using Frapid.Dashboard.Controllers;
using MixERP.Sales.DAL.Backend.Widgets;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Widgets
{
    public class TopCustomersController : BackendController
    {
        [Route("dashboard/sales/widgets/top-customers")]
        [FrapidOutputCache(Duration = 60 * 60, Location = OutputCacheLocation.Client)]
        [AccessPolicy("inventory", "top_customers_by_office_view", AccessTypeEnum.Read)]
        public async Task<ActionResult> GetAsync()
        {
            var meta = await AppUsers.GetCurrentAsync();

            try
            {
                var model = await TopCustomers.GetAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);
                return this.Ok(model);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}