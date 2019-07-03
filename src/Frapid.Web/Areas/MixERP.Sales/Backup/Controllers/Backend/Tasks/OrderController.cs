using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using MixERP.Sales.DAL.Backend.Tasks;
using MixERP.Sales.DTO;
using MixERP.Sales.QueryModels;
using Frapid.Areas.CSRF;
using Frapid.DataAccess.Models;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    [AntiForgery]
    public class OrderController : SalesDashboardController
    {
        [Route("dashboard/sales/tasks/order/checklist/{tranId}")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/order")]
        [AccessPolicy("sales", "orders", AccessTypeEnum.Read)]
        public ActionResult CheckList(long tranId)
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Order/CheckList.cshtml", this.Tenant), tranId);
        }

        [Route("dashboard/sales/tasks/order/search")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/order")]
        [AccessPolicy("sales", "orders", AccessTypeEnum.Read)]
        [HttpPost]
        public async Task<ActionResult> SearchAsync(OrderSearch search)
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            search.From = search.From == DateTime.MinValue ? DateTime.Today : search.From;
            search.To = search.To == DateTime.MinValue ? DateTime.Today : search.To;
            search.ExpectedFrom = search.ExpectedFrom == DateTime.MinValue ? DateTime.Today : search.ExpectedFrom;
            search.ExpectedTo = search.ExpectedTo == DateTime.MinValue ? DateTime.Today : search.ExpectedTo;

            try
            {
                var result = await Orders.GetSearchViewAsync(this.Tenant, meta.OfficeId, search).ConfigureAwait(true);
                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/sales/tasks/order/merge-model/{orderId}")]
        [AccessPolicy("sales", "order_details", AccessTypeEnum.Read)]
        public async Task<ActionResult> GetMergeModelAsync(long orderId)
        {
            var model = await Orders.GetMergeModelAsync(this.Tenant, orderId).ConfigureAwait(true);
            return this.Ok(model);
        }

        [Route("dashboard/sales/tasks/order/view")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/order")]
        [AccessPolicy("sales", "orders", AccessTypeEnum.Read)]
        public async Task<ActionResult> ViewAsync(OrderQueryModel query)
        {
            try
            {
                var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(false);

                query.UserId = meta.UserId;
                query.OfficeId = meta.OfficeId;

                var model = await Orders.GetOrderResultViewAsync(this.Tenant, query).ConfigureAwait(true);
                return this.Ok(model);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }


        [Route("dashboard/sales/tasks/order")]
        [MenuPolicy]
        [AccessPolicy("sales", "orders", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Order/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/tasks/order/verification")]
        [MenuPolicy]
        [AccessPolicy("sales", "orders", AccessTypeEnum.Verify)]
        public ActionResult Verification()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Order/Verification.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/tasks/order/new")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/order")]
        [AccessPolicy("sales", "orders", AccessTypeEnum.Read)]
        public ActionResult New()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Order/New.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/tasks/order/{id}/cancel")]
        [HttpDelete]
        [AccessPolicy("sales", "orders", AccessTypeEnum.Delete)]
        public async Task<ActionResult> CancelAsync(long id)
        {
            if (id <= 0)
            {
                return this.Failed("Invalid id supplied.", HttpStatusCode.BadRequest);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            try
            {
                await Orders.CancelAsync(this.Tenant, id, meta).ConfigureAwait(true);
                return this.Ok();
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/sales/tasks/order/new")]
        [HttpPost]
        [AccessPolicy("sales", "orders", AccessTypeEnum.Create)]
        public async Task<ActionResult> PostAsync(Order model)
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
                long tranId = await Orders.PostAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(tranId);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}