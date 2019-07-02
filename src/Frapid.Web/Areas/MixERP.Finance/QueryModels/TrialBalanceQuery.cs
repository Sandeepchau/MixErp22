using System;
using System.ComponentModel.DataAnnotations;

namespace MixERP.Finance.QueryModels
{
    public sealed class TrialBalanceQuery
    {
        [Required]
        public DateTime From { get; set; }

        [Required]
        public DateTime To { get; set; }

        public int Factor { get; set; }
        public bool ChangeSide { get; set; }
    }
}