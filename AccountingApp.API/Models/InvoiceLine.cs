using System;

namespace AccountingApp.API.Models
{
    public class InvoiceLine : BaseEntity<Guid>
    {
        public Guid InvoiceId { get; set; }
        public Invoice Invoice { get; set; } = null!;

        public int ProductId { get; set; }
        public Product Product { get; set; } = null!;

        public decimal Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal TaxRate { get; set; } // Kdv oranı (%)
        public decimal LineTotal { get; set; }
    }
}
