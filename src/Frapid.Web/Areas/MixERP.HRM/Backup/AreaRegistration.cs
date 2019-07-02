using System.Web.Mvc;
using Frapid.Areas;

namespace MixERP.HRM
{
    public class AreaRegistration : FrapidAreaRegistration
    {
        public override string AreaName => "MixERP.HRM";

        public override void RegisterArea(AreaRegistrationContext context)
        {
            context.Routes.LowercaseUrls = true;
            context.Routes.MapMvcAttributeRoutes();
        }
    }
}