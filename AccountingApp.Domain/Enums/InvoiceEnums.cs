namespace AccountingApp.Domain.Enums;

public enum InvoiceType
{
    Incoming = 1,
    Outgoing = 2
}

public enum InvoiceStatus
{
    Pending = 1,
    Paid = 2,
    Overdue = 3,
    Cancelled = 4
}
