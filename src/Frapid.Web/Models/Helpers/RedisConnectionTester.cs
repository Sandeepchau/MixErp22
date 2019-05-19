using StackExchange.Redis;
using System;

namespace Frapid.Web.Models.Helpers
{
    internal static class RedisConnectionTester
    {
        internal static string Test(string connectionString)
        {
            try
            {
                var Redis = ConnectionMultiplexer.Connect(connectionString);
                Redis.PreserveAsyncOrder = false;
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }

            return "Connection to Redis was successful.";
        }

    }
}
