using System;

namespace AccountingApp.API.Models
{
    public enum TransactionType : byte
    {
        Collection = 1, // Tahsilat / Gelir
        Payment = 2 // Ödeme / Gider
    }

    public enum PaymentMethod : byte
    {
        Cash = 1,
        BankTransfer = 2,
        CreditCard = 3
    }

    public class Transaction : BaseEntity<Guid>
    {
        public Guid? BusinessContactId { get; set; }
        public BusinessContact BusinessContact { get; set; } = null!;

        public Guid? InvoiceId { get; set; }
        public Invoice Invoice { get; set; } = null!;

        public TransactionType Type { get; set; }
        public decimal Amount { get; set; }

        public int CurrencyId { get; set; }
        public Currency Currency { get; set; } = null!;

        public decimal ExchangeRate { get; set; }

        public DateTime Date { get; set; }
        public PaymentMethod PaymentMethod { get; set; }

        public string Description { get; set; } = string.Empty;

        public Guid CreatedById { get; set; }
        public User CreatedBy { get; set; } = null!;
    }
}
