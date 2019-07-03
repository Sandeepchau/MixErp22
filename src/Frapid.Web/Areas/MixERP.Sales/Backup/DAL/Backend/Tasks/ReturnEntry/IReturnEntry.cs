using System.Threading.Tasks;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.DAL.Backend.Tasks.ReturnEntry
{
    public interface IReturnEntry
    {
        Task<long> PostAsync(string tenant, SalesReturn model);
    }
}