using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

namespace MixERP.HRM.ViewModels
{
    [Table("Timesheet")]
    public sealed class Timesheet
    {
        public int TimesheetID { get; set; }
        public int UserId { get; set; }

        [Required]
        public string FirstName { get; set; }
        [Required]
        public string MiddleName { get; set; }
        [Required]
        public string LastName { get; set; }
        
    }
}