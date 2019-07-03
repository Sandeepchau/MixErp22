using System.Collections.Generic;
using MixERP.Sales.DTO;

namespace MixERP.Sales.ViewModels
{
    public class ClosingCashViewModel
    {
        public OpeningCash OpeningCashInfo { get; set; }
        public IEnumerable<SalesView> SalesView { get; set; }
        public ClosingCash ClosingCashInfo { get; set; }
    }
}