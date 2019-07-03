using System;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Areas.CSRF;
using Frapid.Dashboard;
using MixERP.Sales.DAL.Backend.Tasks;
using MixERP.Sales.ViewModels;
using Frapid.DataAccess.Models;
using MixERP.Sales.QueryModels;

namespace MixERP.Sales.Controllers.Backend.Tasks
{
    [AntiForgery]
    public sealed class ReceiptController : SalesDashboardController
    {
        [Route("dashboard/sales/tasks/receipt/checklist/{tranId}")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/receipt")]
        [AccessPolicy("sales", "customer_receipts", AccessTypeEnum.Read)]
        public ActionResult CheckList(long tranId)
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Receipt/CheckList.cshtml", this.Tenant), tranId);
        }

        [Route("dashboard/sales/tasks/receipt/search")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/receipt")]
        [AccessPolicy("sales", "sales", AccessTypeEnum.Read)]
        [HttpPost]
        public async Task<ActionResult> SearchAsync(ReceiptSearch search)
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            search.From = search.From == DateTime.MinValue ? DateTime.Today : search.From;
            search.To = search.To == DateTime.MinValue ? DateTime.Today : search.To;

            try
            {
                var result = await Receipts.GetSearchViewAsync(this.Tenant, meta.OfficeId, search).ConfigureAwait(true);
                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/sales/tasks/receipt")]
        [MenuPolicy]
        [AccessPolicy("sales", "customer_receipts", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Receipt/Index.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/tasks/receipt/verification")]
        [MenuPolicy]
        [AccessPolicy("sales", "customer_receipts", AccessTypeEnum.Verify)]
        public ActionResult Verification()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Receipt/Verification.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/tasks/receipt/new")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/receipt")]
        [AccessPolicy("sales", "customer_receipts", AccessTypeEnum.Read)]
        public ActionResult New()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Tasks/Receipt/New.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/tasks/receipt/merchant-fee-setup/{merchantAccountId}/{paymentCardId}")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/receipt")]
        [AccessPolicy("finance", "merchant_fee_setup", AccessTypeEnum.Read)]
        public async Task<ActionResult> GetMerchantFeeSetupAsync(int merchantAccountId, int paymentCardId)
        {
            var model = await Receipts.GetMerchantFeeSetupAsync(this.Tenant, merchantAccountId, paymentCardId).ConfigureAwait(true);
            return this.Ok(model);
        }

        [Route("dashboard/sales/tasks/receipt/home-currency")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/receipt")]
        [AccessPolicy("core", "offices", AccessTypeEnum.Read)]
        public async Task<ActionResult> GetHomeCurrencyAsync()
        {
            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            string homeCurrency = await Receipts.GetHomeCurrencyAsync(this.Tenant, meta.OfficeId).ConfigureAwait(true);
            return this.Ok(homeCurrency);
        }

        [Route("dashboard/sales/tasks/receipt/exchange-rate/{sourceCurrencyCode}/{destinationCurrencyCode}")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/receipt")]
        [AccessPolicy("finance", "exchange_rates", AccessTypeEnum.Read)]
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
            decimal exchangeRate = await Receipts.GetExchangeRateAsync(this.Tenant, meta.OfficeId, sourceCurrencyCode, destinationCurrencyCode).ConfigureAwait(true);
            return this.Ok(exchangeRate);
        }

        [Route("dashboard/sales/tasks/receipt/customer/transaction-summary/{customerId}")]
        [MenuPolicy(OverridePath = "/dashboard/sales/tasks/receipt")]
        [AccessPolicy("core", "currencies", AccessTypeEnum.Read)]
        public async Task<ActionResult> GetCustomerTransactionSummaryAsync(int customerId)
        {
            if (customerId <= 0)
            {
                return this.Failed(I18N.BadRequest, HttpStatusCode.BadRequest);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);
            var summary = await Receipts.GetCustomerTransactionSummaryAsync(this.Tenant, meta.OfficeId, customerId).ConfigureAwait(true);
            return this.Ok(summary);
        }


        [HttpPost]
        [Route("dashboard/sales/tasks/receipt/new")]
        [AccessPolicy("sales", "customer_receipts", AccessTypeEnum.Create)]
        public async Task<ActionResult> PostAsync(SalesReceipt model)
        {
            if (!this.ModelState.IsValid)
            {
                return this.InvalidModelState(this.ModelState);
            }

            if (model.CashRepositoryId == 0 && model.BankAccountId == 0)
            {
                this.Failed(I18N.InvalidReceiptMode, HttpStatusCode.InternalServerError);
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
                long tranId = await Receipts.PostAsync(this.Tenant, model).ConfigureAwait(true);
                return this.Ok(tranId);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}