using System;
using Frapid.Dashboard.Controllers;

namespace MixERP.Sales.Controllers
{
    public class SalesDashboardController : DashboardController
    {
        public SalesDashboardController()
        {
            this.ViewBag.SalesLayoutPath = this.GetLayoutPath();
        }

        private string GetLayoutPath()
        {
            return this.GetRazorView<AreaRegistration>("Layout.cshtml", this.Tenant);
        }
    }
}