using System;
using System.Collections.Generic;

namespace AccountingApp.API.Models
{
    public enum ContactType : byte
    {
        Customer = 1,
        Supplier = 2,
        Other = 3
    }

    public class BusinessContact : BaseEntity<Guid>
    {
        public ContactType Type { get; set; }
        
        public string Name { get; set; } = string.Empty; // Firma veya Şahıs adı
        public string TaxNumber { get; set; } = string.Empty;
        public string TaxOffice { get; set; } = string.Empty;
        
        public string Email { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;

        public ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();
        public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    }
}
