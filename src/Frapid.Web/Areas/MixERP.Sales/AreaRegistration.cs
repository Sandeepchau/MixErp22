using System.Web.Mvc;
using Frapid.Areas;

namespace MixERP.Sales
{
    public class AreaRegistration : FrapidAreaRegistration
    {
        public override string AreaName => "MixERP.Sales";

        public override void RegisterArea(AreaRegistrationContext context)
        {
            context.Routes.LowercaseUrls = true;
            context.Routes.MapMvcAttributeRoutes();
        }
    }
}