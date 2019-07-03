using System;
using System.Collections.Generic;
using System.Net;
using System.Threading.Tasks;
using System.Web.Mvc;
using Frapid.ApplicationState.Cache;
using Frapid.Dashboard;
using Frapid.DataAccess.Models;
using MixERP.Sales.DAL.Backend.Setup;
using MixERP.Sales.DTO;

namespace MixERP.Sales.Controllers.Backend.Setups
{
    public class SellingPriceController : SalesDashboardController
    {
        [Route("dashboard/sales/setup/selling-prices")]
        [MenuPolicy]
        [AccessPolicy("sales", "item_selling_prices", AccessTypeEnum.Read)]
        public ActionResult Index()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/SellingPrices.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/setup/selling-prices/customer")]
        [MenuPolicy]
        [AccessPolicy("sales", "customerwise_selling_prices", AccessTypeEnum.Read)]
        public ActionResult Customer()
        {
            return this.FrapidView(this.GetRazorView<AreaRegistration>("Setup/CustomerSellingPrices.cshtml", this.Tenant));
        }

        [Route("dashboard/sales/setup/selling-prices/{customerId}/price-list")]
        [MenuPolicy(OverridePath = "/dashboard/sales/setup/selling-prices/customer")]
        [AccessPolicy("sales", "customerwise_selling_prices", AccessTypeEnum.Read)]
        public async Task<ActionResult> GetPriceListAsync(int customerId)
        {
            if (customerId <= 0)
            {
                return this.Failed(I18N.BadRequest, HttpStatusCode.BadRequest);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            try
            {
                var result = await SellingPrices.GetSellingPrices(this.Tenant, meta.OfficeId, customerId).ConfigureAwait(true);
                return this.Ok(result);
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }

        [Route("dashboard/sales/setup/selling-prices/{customerId}/price-list")]
        [MenuPolicy(OverridePath = "/dashboard/sales/setup/selling-prices/customer")]
        [AccessPolicy("sales", "customerwise_selling_prices", AccessTypeEnum.Execute)]
        [HttpPost]
        public async Task<ActionResult> SetPriceListAsync(int customerId, IEnumerable<CustomerwiseSellingPrice> model)
        {
            if (customerId <= 0)
            {
                return this.Failed(I18N.BadRequest, HttpStatusCode.BadRequest);
            }

            var meta = await AppUsers.GetCurrentAsync().ConfigureAwait(true);

            try
            {
                await SellingPrices.SetPriceList(this.Tenant, meta.UserId, customerId, model).ConfigureAwait(true);
                return this.Ok();
            }
            catch (Exception ex)
            {
                return this.Failed(ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}