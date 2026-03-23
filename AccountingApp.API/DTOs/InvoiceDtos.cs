using System;
using System.Collections.Generic;

namespace AccountingApp.API.DTOs
{
    public class InvoiceListDto
    {
        public Guid Id { get; set; }
        public string InvoiceNumber { get; set; } = string.Empty;
        
        public string ContactName { get; set; } = string.Empty; // BusinessContact.Name
        public byte Type { get; set; } // 1: Sales(Gelir), 2: Purchase(Gider)
        public byte Status { get; set; } // 1: Pending, 2: Paid, 3: Cancelled, 4: Overdue
        
        public DateTime IssueDate { get; set; }
        public DateTime DueDate { get; set; }
        
        public decimal TotalAmount { get; set; }
        public string CurrencyCode { get; set; } = string.Empty; // Currency.Code
    }

    public class InvoiceDetailDto
    {
        public Guid Id { get; set; }
        public string InvoiceNumber { get; set; } = string.Empty;
        
        // Contact Details
        public Guid BusinessContactId { get; set; }
        public string ContactName { get; set; } = string.Empty;
        public string ContactTaxNumber { get; set; } = string.Empty;
        public string ContactTaxOffice { get; set; } = string.Empty;
        public string ContactAddress { get; set; } = string.Empty;
        
        public byte Type { get; set; }
        public byte Status { get; set; }
        
        public DateTime IssueDate { get; set; }
        public DateTime DueDate { get; set; }
        
        // Sums
        public decimal SubTotal { get; set; } // Calculated: TotalAmount - TaxAmount
        public decimal TaxAmount { get; set; }
        public decimal TotalAmount { get; set; }
        
        public int CurrencyId { get; set; }
        public string CurrencyCode { get; set; } = string.Empty;
        public decimal ExchangeRate { get; set; }
        
        // Lines
        public List<InvoiceLineDto> Lines { get; set; } = new List<InvoiceLineDto>();
        
        // Custom requirements
        public string WaybillNumber { get; set; } = string.Empty; // İrsaliye no (Opsiyonel, string eklenebilir veya açıklama alanı kullanılabilir)
        public string PaymentTerms { get; set; } = string.Empty; // Ödeme koşulları
    }

    public class InvoiceLineDto
    {
        public Guid Id { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public decimal Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal TaxRate { get; set; }
        public decimal LineTotal { get; set; }
    }

    // Creating Invoices
    
    public class InvoiceCreateDto
    {
        public string? InvoiceNumber { get; set; }
        public Guid BusinessContactId { get; set; }
        public byte Type { get; set; } // Sales or Purchase
        public DateTime IssueDate { get; set; }
        public DateTime DueDate { get; set; }
        public int CurrencyId { get; set; }
        public decimal ExchangeRate { get; set; } = 1.0m;
        
        public List<InvoiceLineCreateDto> Lines { get; set; } = new List<InvoiceLineCreateDto>();
        
        public string? WaybillNumber { get; set; }
        public string? PaymentTerms { get; set; }
        
        /// <summary>
        /// Optional: set initial status. If null, auto-set based on Type.
        /// Purchase → Pending(1), Sales → ToBeIssued(6)
        /// </summary>
        public byte? Status { get; set; }
    }

    public class InvoiceLineCreateDto
    {
        public int ProductId { get; set; }
        public decimal Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal TaxRate { get; set; }
    }
}
