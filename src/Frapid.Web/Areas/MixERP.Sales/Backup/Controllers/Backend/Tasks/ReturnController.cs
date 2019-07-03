using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Areas.CSRF;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;
using MixERP.Sales.DAL.Backend.Tasks;
using MixERP.Sales.QueryModels;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    [AntiForgery]
    public class ReturnController : SalesDashboardController
    {
        [Route("dashboard/sales/tasks/return/checklist/{tranId}")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/return")]
        [AccessPolicy("sales", "returns", AccessTypeEnum.Read)]
        public ActionResult CheckList(long tranId)
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Return/CheckList.cshtml", this.Tenant), tranId);
        }

        [Route("dashboard/sales/tasks/return/search")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/return")]
        [AccessPolicy("sales", "returns", AccessTypeEnum.Read)]
        [HttpPost]
        public async Task<ActionResult> SearchAsync(ReturnSearch search)
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            search.From = search.From == DateTime.MinValue ? DateTime.Today : search.From;
            search.To = search.To == DateTime.MinValue ? DateTime.Today : search.To;

            try
            {
                var result = await SalesReturnEntries.GetSearchViewAsync(this.Tenant, meta.OfficeId, search).ConfigureAwait(true);
                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/sales/tasks/return")]
        [MenuPolicy]
        [AccessPolicy("sales", "returns", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Return/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/tasks/return/verification")]
        [MenuPolicy]
        [AccessPolicy("sales", "returns", AccessTypeEnum.Verify)]
        public ActionResult Verification()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Return/Verification.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/tasks/return/new")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/return")]
        [AccessPolicy("sales", "returns", AccessTypeEnum.Read)]
        public ActionResult New()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Return/New.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/tasks/return/new")]
        [HttpPost]
        [AccessPolicy("sales", "returns", AccessTypeEnum.Create)]
        public async Task<ActionResult> PostAsync(SalesReturn model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            model.UserId = meta.UserId;
            model.OfficeId = meta.OfficeId;
            model.LoginId = meta.LoginId;

            try
            {
                long tranId = await SalesReturnEntries.PostAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(tranId);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}