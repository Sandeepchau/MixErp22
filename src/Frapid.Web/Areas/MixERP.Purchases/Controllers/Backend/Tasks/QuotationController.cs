using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using MixERP.Purchases.DAL.Backend.Tasks;
using MixERP.Purchases.DTO;
using MixERP.Purchases.QueryModels;
using Frapid.Areas.CSRF;
using Frapid.DataAccess.Models;

namespace MixERP.Purchases.Controllers.Backend.Tasks
{
    [AntiForgery]
    public class QuotationController : PurchaseDashboardController
    {
        [Route("dashboard/purchase/tasks/quotation/checklist/{tranId}")]
        [MenuPolicy(OverridePath = "/dashboard/purchase/tasks/quotation")]
        [AccessPolicy("purchase", "quotations", AccessTypeEnum.Read)]
        public ActionResult CheckList(long tranId)
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Quotation/CheckList.cshtml", this.Tenant), tranId);
        }

        [Route("dashboard/purchase/tasks/quotation/view")]
        [MenuPolicy(OverridePath = "/dashboard/purchase/tasks/quotation")]
        [AccessPolicy("purchase", "quotations", AccessTypeEnum.Read)]
        public async Task<ActionResult> ViewAsync(QuotationQueryModel query)
        {
            try
            {
                var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(false);

                query.UserId = meta.UserId;
                query.OfficeId = meta.OfficeId;

                var model = await Quotations.GetQuotationResultViewAsync(this.Tenant, query).ConfigureAwait(true);
                return this.Ok(model);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/purchase/tasks/quotation/search")]
        [MenuPolicy(OverridePath = "/dashboard/purchase/tasks/quotation")]
        [AccessPolicy("purchase", "quotations", AccessTypeEnum.Read)]
        [HttpPost]
        public async Task<ActionResult> SearchAsync(QuotationSearch search)
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            search.From = search.From == DateTime.MinValue ? DateTime.Today : search.From;
            search.To = search.To == DateTime.MinValue ? DateTime.Today : search.To;

            try
            {
                var result = await Quotations.GetSearchViewAsync(this.Tenant, meta.OfficeId, search).ConfigureAwait(true);
                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/purchase/tasks/quotation")]
        [MenuPolicy]
        [AccessPolicy("purchase", "quotations", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Quotation/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/purchase/tasks/quotation/verification")]
        [MenuPolicy]
        public ActionResult Verification()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Quotation/Verification.cshtml", this.Tenant));
        }

        [Route("dashboard/purchase/tasks/quotation/new")]
        [MenuPolicy(OverridePath = "/dashboard/purchase/tasks/quotation")]
        [AccessPolicy("purchase", "quotations", AccessTypeEnum.Read)]
        public ActionResult New()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Quotation/New.cshtml", this.Tenant));
        }



        [Route("dashboard/purchase/tasks/quotation/{id}/cancel")]
        [HttpDelete]
        [AccessPolicy("purchase", "quotations", AccessTypeEnum.Delete)]
        public async Task<ActionResult> CancelAsync(long id)
        {
            if (id <= 0)
            {
                return this.Failed("Invalid id supplied.", HttpStatusCode.BadRequest);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            try
            {
                await Quotations.CancelAsync(this.Tenant, id, meta).ConfigureAwait(true);
                return this.Ok();
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/purchase/tasks/quotation/new")]
        [HttpPost]
        [AccessPolicy("purchase", "quotations", AccessTypeEnum.Create)]
        public async Task<ActionResult> PostAsync(Quotation model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            model.UserId = meta.UserId;
            model.OfficeId = meta.OfficeId;
            model.AuditUserId = meta.UserId;
            model.AuditTs = DateTimeOffset.UtcNow;
            model.TransactionTimestamp = DateTimeOffset.UtcNow;

            try
            {
                long tranId = await Quotations.PostAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(tranId);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}