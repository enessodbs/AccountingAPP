using System;
using System.ComponentModel.DataAnnotations;

namespace AccountingApp.API.DTOs
{
    public class TransactionDto
    {
        public Guid Id { get; set; }

        public Guid? BusinessContactId { get; set; }
        public string BusinessContactName { get; set; } = string.Empty;

        public Guid? InvoiceId { get; set; }
        public string InvoiceNumber { get; set; } = string.Empty;

        public byte Type { get; set; } // 1: Collection, 2: Payment
        public decimal Amount { get; set; }

        public int CurrencyId { get; set; }
        public string CurrencyCode { get; set; } = string.Empty;
        public string CurrencySymbol { get; set; } = string.Empty;
        public decimal ExchangeRate { get; set; }

        public DateTime Date { get; set; }
        public byte PaymentMethod { get; set; } // 1: Cash, 2: BankTransfer, 3: CreditCard

        public string Description { get; set; } = string.Empty;

        public Guid CreatedById { get; set; }
        public bool IsActive { get; set; }
    }

    public class TransactionCreateDto
    {
        public Guid? BusinessContactId { get; set; }
        public Guid? InvoiceId { get; set; }

        [Required]
        public byte Type { get; set; }

        [Range(0.01, double.MaxValue)]
        public decimal Amount { get; set; }

        [Required]
        public int CurrencyId { get; set; }

        public decimal ExchangeRate { get; set; } = 1.0m;

        [Required]
        public DateTime Date { get; set; }

        [Required]
        public byte PaymentMethod { get; set; }

        public string Description { get; set; } = string.Empty;
    }
}
