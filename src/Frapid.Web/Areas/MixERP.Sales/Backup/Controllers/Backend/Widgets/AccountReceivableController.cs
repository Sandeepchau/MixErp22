using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using System.Web.UI;
using Frapid.ApplicationState.Cache;
using Frapid.Areas.Caching;
using Frapid.Dashboard.Controllers;
using MixERP.Sales.DAL.Backend.Widgets;
using Frapid.DataAccess.Models;
using Frapid.Dashboard;

namespace MixERP.Sales.Controllers.Backend.Widgets
{
    public class AccountReceivablesController : BackendController
    {
        [Route("dashboard/sales/widgets/account-receivables")]
        [FrapidOutputCache(Duration = 2, Location = OutputCacheLocation.Client)]
        [AccessPolicy("finance", "transaction_master", AccessTypeEnum.Read)]
        public async Task<ActionResult> GetAsync()
        {
            var meta = await AppUsers.GetCurrentAsync();

            try
            {
                var model = await AccountReceivables.GetAsync(this.Tenant, meta.OfficeId);
                return this.Ok(model);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}