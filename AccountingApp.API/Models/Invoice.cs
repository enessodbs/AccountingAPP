using System;
using System.Collections.Generic;

namespace AccountingApp.API.Models
{
    public enum InvoiceType : byte
    {
        Sales = 1, // Gelir
        Purchase = 2 // Gider
    }

    public enum InvoiceStatus : byte
    {
        Pending = 1,      // Bekliyor / Ödenmemiş (Gelen fatura)
        Paid = 2,         // Ödenmiş (Gelen fatura)
        Cancelled = 3,    // İptal
        Overdue = 4,      // Gecikmiş
        Issued = 5,       // Kesilmiş (Giden fatura kesildi)
        ToBeIssued = 6,   // Kesilecek (Giden fatura henüz kesilmedi)
        Proforma = 7      // Teklif (Proforma)
    }

    public class Invoice : BaseEntity<Guid>
    {
        public string InvoiceNumber { get; set; } = string.Empty;
        
        public Guid BusinessContactId { get; set; }
        public BusinessContact BusinessContact { get; set; } = null!;

        public InvoiceType Type { get; set; }
        public InvoiceStatus Status { get; set; }

        public DateTime IssueDate { get; set; }
        public DateTime DueDate { get; set; }

        public decimal TotalAmount { get; set; }
        public decimal TaxAmount { get; set; }

        public int CurrencyId { get; set; }
        public Currency Currency { get; set; } = null!;

        public decimal ExchangeRate { get; set; }

        // Additional information based on requirements
        public string WaybillNumber { get; set; } = string.Empty; // İrsaliye numarası
        public string PaymentTerms { get; set; } = string.Empty; // Ödeme koşulları

        public Guid CreatedById { get; set; }
        public User CreatedBy { get; set; } = null!;

        public ICollection<InvoiceLine> InvoiceLines { get; set; } = new List<InvoiceLine>();
        public ICollection<StockMovement> StockMovements { get; set; } = new List<StockMovement>();
        public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    }
}
