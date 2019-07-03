using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Areas.CSRF;
using Frapid.Dashboard;
using MixERP.Purchases.DAL.Backend.Tasks;
using MixERP.Purchases.ViewModels;
using Frapid.DataAccess.Models;
using MixERP.Purchases.QueryModels;

namespace MixERP.Purchases.Controllers.Backend.Tasks
{
    [AntiForgery]
    public sealed class PaymentController : PurchaseDashboardController
    {
        [Route("dashboard/purchase/tasks/payment/checklist/{tranId}")]
        [MenuPolicy(OverridePath = "/dashboard/purchase/tasks/payment")]
        [AccessPolicy("purchase", "supplier_payments", AccessTypeEnum.Read)]
        public ActionResult CheckList(long tranId)
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Payment/CheckList.cshtml", this.Tenant), tranId);
        }

        [Route("dashboard/purchase/tasks/payment")]
        [MenuPolicy]
        [AccessPolicy("purchase", "supplier_payments", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Payment/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/purchase/tasks/payment/search")]
        [MenuPolicy(OverridePath = "/dashboard/purchase/tasks/payment")]
        [AccessPolicy("purchase", "supplier_payments", AccessTypeEnum.Read)]
        [HttpPost]
        public async Task<ActionResult> SearchAsync(SupplierPaymentSearch search)
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            search.From = search.From == DateTime.MinValue ? DateTime.Today : search.From;
            search.To = search.To == DateTime.MinValue ? DateTime.Today : search.To;

            try
            {
                var result = await Payments.GetSearchViewAsync(this.Tenant, meta.OfficeId, search).ConfigureAwait(true);
                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/purchase/tasks/payment/verification")]
        [MenuPolicy]
        [AccessPolicy("purchase", "supplier_payments", AccessTypeEnum.Verify)]
        public ActionResult Verification()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Payment/Verification.cshtml", this.Tenant));
        }

        [Route("dashboard/purchase/tasks/payment/new")]
        [MenuPolicy(OverridePath = "/dashboard/purchase/tasks/payment")]
        [AccessPolicy("purchase", "supplier_payments", AccessTypeEnum.Read)]
        public ActionResult New()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Payment/New.cshtml", this.Tenant));
        }

        [Route("dashboard/purchase/tasks/payment/home-currency")]
        [MenuPolicy(OverridePath = "/dashboard/purchase/tasks/payment")]
        public async Task<ActionResult> GetHomeCurrencyAsync()
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            string homeCurrency = await Payments.GetHomeCurrencyAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);
            return this.Ok(homeCurrency);
        }

        [Route("dashboard/purchase/tasks/payment/exchange-rate/{sourceCurrencyCode}/{destinationCurrencyCode}")]
        [MenuPolicy(OverridePath = "/dashboard/purchase/tasks/payment")]
        public async Task<ActionResult> GetHomeCurrencyAsync(string sourceCurrencyCode, string destinationCurrencyCode)
        {
            if (string.IsNullOrWhiteSpace(sourceCurrencyCode) || string.IsNullOrWhiteSpace(destinationCurrencyCode))
            {
                return this.Failed(I18N.BadRequest, HttpStatusCode.BadRequest);
            }

            if (sourceCurrencyCode == destinationCurrencyCode)
            {
                return this.Ok(1.0);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            decimal exchangeRate = await Payments.GetExchangeRateAsync(this.Tenant, meta.OfficeId, sourceCurrencyCode, destinationCurrencyCode).ConfigureAwait(true);
            return this.Ok(exchangeRate);
        }

        [Route("dashboard/purchase/tasks/payment/supplier/transaction-summary/{supplierId}")]
        [MenuPolicy(OverridePath = "/dashboard/purchase/tasks/payment")]
        [AccessPolicy("purchase", "supplier_payments", AccessTypeEnum.Read)]
        public async Task<ActionResult> GetSupplierTransactionSummaryAsync(int supplierId)
        {
            if (supplierId <= 0)
            {
                return this.Failed(I18N.BadRequest, HttpStatusCode.BadRequest);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            try
            {
                var summary = await Payments.GetSupplierTransactionSummaryAsync(this.Tenant, meta.OfficeId, supplierId).ConfigureAwait(true);
                return this.Ok(summary);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [HttpPost]
        [Route("dashboard/purchase/tasks/payment/new")]
        [AccessPolicy("purchase", "supplier_payments", AccessTypeEnum.Create)]
        public async Task<ActionResult> PostAsync(Payment model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

            if (model.CashRepositoryId == 0 && model.BankAccountId == 0)
            {
                this.Failed(I18N.InvalidPaymentMode, HttpStatusCode.InternalServerError);
            }

            if (model.CashRepositoryId > 0 && (model.BankAccountId > 0 || !string.IsNullOrWhiteSpace(model.BankInstrumentCode) || !string.IsNullOrWhiteSpace(model.BankInstrumentCode)))
            {
                this.Failed(I18N.CashTransactionCannotContainBankTransactionDetails, HttpStatusCode.InternalServerError);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            model.UserId = meta.UserId;
            model.OfficeId = meta.OfficeId;
            model.LoginId = meta.LoginId;

            try
            {
                long tranId = await Payments.PostAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(tranId);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}