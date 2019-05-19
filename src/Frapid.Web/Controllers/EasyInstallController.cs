using System.Web.Hosting;
using System.Web.Mvc;
using Frapid.Configuration.TenantServices;
using Frapid.Web.ViewModels;
using System.IO;
using System.Net;
using System.Net.Mime;
using System.Text;
using Newtonsoft.Json;
using System;
using Frapid.Web.Models;
using Frapid.Web.Models.Helpers;

namespace Frapid.Web.Controllers
{
    public class EasyInstallController : Controller
    {
        private ActionResult Failed(string message, HttpStatusCode statusCode)
        {
            this.Response.StatusCode = (int)statusCode;
            return this.Json(message, MediaTypeNames.Text.Plain, Encoding.UTF8, JsonRequestBehavior.AllowGet);
        }
        private ActionResult OK(string message)
        {
            this.Response.StatusCode = 200;
            return this.Json(message, MediaTypeNames.Text.Plain, Encoding.UTF8, JsonRequestBehavior.AllowGet);
        }

        [Route("easy-install")]
        public ActionResult Index()
        {
            bool easyInstall = System.Configuration.ConfigurationManager.AppSettings["EasyInstall"].ToLowerInvariant() == "true";

            if (!easyInstall)
            {
                return this.Failed("Access is denied. In order to use this feature, please enter a key named EasyInstall with value true on Web.config/AppSettings.", System.Net.HttpStatusCode.Conflict);
            }

            if (!Directory.Exists(HostingEnvironment.MapPath("~/Resources/_Configs")))
            {
                return this.Failed("Cannot continue. The configuration template directory: /Resources/_Configs was not found.", System.Net.HttpStatusCode.Conflict);
            }

            var model = EasyInstallConfigFile.Get();

            if (model == null)
            {
                model = new InstallViewModel
                {
                    DomainName = this.Request.Url.Host,
                    DatabaseName = ByConvention.ConvertToTenantName(this.Request.Url.Host),
                    SqlServer = new SqlServerConfig(),
                    PostgreSQL = new PostgreSQLConfig()
                };
            }

            return this.View("~/Views/EasyInstall.cshtml", model);
        }

        [Route("easy-install")]
        [HttpPut]
        public ActionResult Save(InstallViewModel model)
        {
            EasyInstallModel.Save(model);
            return this.OK("Configuration saved.");
        }

        [Route("easy-install/test-redis")]
        [HttpPut]
        public ActionResult TestRedis()
        {
            string result = EasyInstallModel.TestRedis();

            if (result.StartsWith("Error"))
            {
                return this.Failed(result, HttpStatusCode.InternalServerError);
            }

            return this.OK(result);
        }

        [Route("easy-install/test-sql-server")]
        [HttpPut]
        public ActionResult TestSqlServer()
        {
            string result = EasyInstallModel.TestSqlServer();

            if (result.StartsWith("Error"))
            {
                return this.Failed(result, HttpStatusCode.InternalServerError);
            }

            return this.OK(result);
        }

        [Route("easy-install/test-postgresql")]
        [HttpPut]
        public ActionResult TestPostgreSQL()
        {
            string result = EasyInstallModel.TestPostgreSQL();

            if (result.StartsWith("Error"))
            {
                return this.Failed(result, HttpStatusCode.InternalServerError);
            }

            return this.OK(result);
        }

        [Route("easy-install/test-permission")]
        [HttpPut]
        public ActionResult TestPermission()
        {
            var result = EasyInstallModel.TestPermission();
            return this.OK(JsonConvert.SerializeObject(result));
        }

        [Route("easy-install/write-config")]
        [HttpPost]
        public ActionResult WriteConfig()
        {
            try
            {
                var result = EasyInstallModel.WriteConfig();
                return this.OK(JsonConvert.SerializeObject(result));
            }
            catch (Exception ex)
            {
                return this.Failed("Error: " + ex.Message, HttpStatusCode.InternalServerError);
            }
        }
    }
}