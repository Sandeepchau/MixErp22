using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using System.Web.UI;
using Frapid.Areas;
using Frapid.Areas.Authorization;
using Frapid.Areas.Caching;
using Frapid.Dashboard;
using MixERP.Sales.DAL.Backend.Service;
using MixERP.Sales.ViewModels;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    public class CustomerSearchController : FrapidController
    {
        [Route("dashboard/sales/setup/customers/search")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/entry")]
        [RestrictAnonymous]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.View("/Areas/MixERP.Sales/Views/Setup/CustomerSearch.cshtml");
        }

        [Route("dashboard/sales/setup/customer/search/{query}")]
        [RestrictAnonymous]
        [FrapidOutputCache(Location = OutputCacheLocation.Client)]
        [AccessPolicy("inventory", "customers", AccessTypeEnum.Read)]
        public async Task<ActionResult> SearchCustomerAsync(string query)
        {
            try
            {
                var result = await Customers.SearchAsync(this.Tenant, query.Replace("\\", "").Trim()).ConfigureAwait(false);
                var model = new CustomerSearchViewModel
                {
                    Items = result
                };

                return this.Ok(model);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}