using System.Net;
using Frapid.Framework;
using Newtonsoft.Json;
using Serilog;

namespace MixERP.Sales
{
    public sealed class ExceptionLogger : IExceptionLogger
    {
        public void LogError()
        {
            try
            {
                using (var client = new WebClient())
                {
                    string json = JsonConvert.SerializeObject(this);
                    client.Headers[HttpRequestHeader.ContentType] = "application/json";

                    client.UploadString("http://exceptions.mixerp.net", "POST", json);
                }
            }
            catch
            {
                Log.Error("Could not log exception to MixERP API endpoint.");
            }
        }

        public string Tenant { get; set; }
        public string OfficeName { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; }
        public string Message { get; set; }
    }
}