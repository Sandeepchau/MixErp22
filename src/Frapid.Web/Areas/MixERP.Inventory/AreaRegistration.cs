using System.Web.Mvc;
using Frapid.Areas;

namespace MixERP.Inventory
{
    public class AreaRegistration : FrapidAreaRegistration
    {
        public override string AreaName => "MixERP.Inventory";

        public override void RegisterArea(AreaRegistrationContext context)
        {
            context.Routes.LowercaseUrls = true;
            context.Routes.MapMvcAttributeRoutes();
        }
    }
}