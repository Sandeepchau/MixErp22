using Frapid.ApplicationState.Models;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.Mapper;
using Frapid.Mapper.Query.Select;
using MixERP.Finance.QueryModels;
using System.Threading.Tasks;

namespace MixERP.Finance.DAL
{
    public class TrialBalanceTree
    {
        public static async Task<dynamic> GetAsync(string tenant, TrialBalanceQuery query,LoginView meta)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT account_id,account_number,account AS title,previous_debit,previous_credit,debit,credit,closing_debit,closing_credit,parent_account_id FROM finance.get_trial_balance_tree(CAST(@0 AS date), CAST(@1 AS date), @2, @3, @4, @5)", query.From, query.To, meta.UserId, meta.OfficeId,query.Factor,query.ChangeSide);
                return await db.SelectAsync<dynamic>(sql).ConfigureAwait(false);
            }
        }
    }
}