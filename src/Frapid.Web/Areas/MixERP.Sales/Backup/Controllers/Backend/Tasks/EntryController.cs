using System;
using System.Collections.Generic;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using Frapid.Areas.CSRF;
using Frapid.DataAccess.Models;
using MixERP.Sales.DAL.Backend.Tasks;
using MixERP.Sales.QueryModels;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    [AntiForgery]
    public sealed class EntryController : SalesDashboardController
    {
        [Route("dashboard/sales/tasks/entry/checklist/{tranId}")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/entry")]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Read)]
        public ActionResult CheckList(long tranId)
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Entry/CheckList.cshtml", this.Tenant), tranId);
        }

        [Route("dashboard/sales/tasks/entry/search")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/entry")]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Read)]
        [HttpPost]
        public async Task<ActionResult> SearchAsync(SalesSearch search)
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            search.From = search.From == DateTime.MinValue ? DateTime.Today : search.From;
            search.To = search.To == DateTime.MinValue ? DateTime.Today : search.To;

            try
            {
                var result = await SalesEntries.GetSearchViewAsync(this.Tenant, meta.OfficeId, search).ConfigureAwait(true);
                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/sales/tasks/entry")]
        [MenuPolicy]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Entry/Index.cshtml", this.Tenant));
        }


        [Route("dashboard/sales/tasks/entry/verification")]
        [MenuPolicy]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Verify)]
        public ActionResult Verification()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Entry/Verification.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/tasks/entry/new")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/entry")]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Read)]
        public ActionResult New()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Entry/New.cshtml", this.Tenant));
        }


        [HttpPost]
        [Route("dashboard/sales/tasks/entry/new")]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Create)]
        public async Task<ActionResult> PostAsync(ViewModels.Sales model)
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
                long tranId = await SalesEntries.PostAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(tranId);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/sales/entry/serial/{transactionMasterId}")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/entry")]
        public async Task<ActionResult> Purchase(long transactionMasterId)
        {
            var model = await SerialNumbers.GetSerialNumberDetails(this.Tenant, transactionMasterId).ConfigureAwait(true);

            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Entry/SerialNumber.cshtml", this.Tenant), model);
        }

        [Route("dashboard/sales/serial/post")]
        [HttpPost]
        public async Task<ActionResult> Post(PostSerial model)
        {
            try
            {
                var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

                bool result = await SerialNumbers.Post(this.Tenant, meta, model)
                    .ConfigureAwait(true);

                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}