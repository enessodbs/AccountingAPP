using System;
using System.Collections.Generic;

namespace AccountingApp.API.DTOs
{
    public class DashboardSummaryDto
    {
        public decimal MonthlyIncome { get; set; }
        public decimal MonthlyExpense { get; set; }
        public int PendingInvoiceCount { get; set; }
        public int OverdueInvoiceCount { get; set; }
        public string CurrencySymbol { get; set; } = "₺";

        public List<UpcomingItemDto> UpcomingItems { get; set; } = new();
        public List<RecentInvoiceDto> RecentInvoices { get; set; } = new();
        public List<StockAlertDto> StockAlerts { get; set; } = new();
        public List<OverdueInvoiceDto> OverdueInvoices { get; set; } = new();
    }

    public class UpcomingItemDto
    {
        public string Title { get; set; } = string.Empty;
        public string Date { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string CurrencySymbol { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty; // "income" or "expense"
    }

    public class RecentInvoiceDto
    {
        public Guid Id { get; set; }
        public string InvoiceNumber { get; set; } = string.Empty;
        public string ContactName { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
        public string CurrencyCode { get; set; } = string.Empty;
        public byte Status { get; set; }
        public DateTime IssueDate { get; set; }
    }

    public class MonthlyChartDto
    {
        public List<MonthlyDataPoint> IncomeData { get; set; } = new();
        public List<MonthlyDataPoint> ExpenseData { get; set; } = new();
    }

    public class MonthlyDataPoint
    {
        public int Month { get; set; }
        public string MonthName { get; set; } = string.Empty;
        public decimal Amount { get; set; }
    }

    public class StockAlertDto
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string ProductCode { get; set; } = string.Empty;
        public decimal CurrentStock { get; set; }
        public decimal MinStock { get; set; }
    }

    public class OverdueInvoiceDto
    {
        public Guid Id { get; set; }
        public string InvoiceNumber { get; set; } = string.Empty;
        public string ContactName { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
        public string CurrencyCode { get; set; } = string.Empty;
        public DateTime DueDate { get; set; }
        public int DaysOverdue { get; set; }
    }
}
