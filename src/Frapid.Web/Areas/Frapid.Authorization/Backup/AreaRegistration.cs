﻿using System.Web.Mvc;
using Frapid.Areas;

namespace Frapid.Authorization
{
    public class AreaRegistration : FrapidAreaRegistration
    {
        public override string AreaName => "Frapid.Authorization";

        public override void RegisterArea(AreaRegistrationContext context)
        {
            context.Routes.LowercaseUrls = true;
            context.Routes.MapMvcAttributeRoutes();
        }
    }
}