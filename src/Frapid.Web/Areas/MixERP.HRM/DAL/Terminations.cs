﻿using System.Threading.Tasks;
using Frapid.WebApi;
using Frapid.WebApi.DataAccess;

namespace MixERP.HRM.DAL
{
    public static class Terminations
    {
        public static async Task VerifyAsync(string tenant, long loginId, int userId, Verification model)
        {
            var repository = new FormRepository("hrm", "terminations", tenant, loginId, userId);
            await repository.VerifyAsync(model).ConfigureAwait(false);
        }
    }
}