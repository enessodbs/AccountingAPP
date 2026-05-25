using AccountingApp.API.Data;
using AccountingApp.API.DTOs;
using AccountingApp.API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AccountingApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class DashboardController : ControllerBase
    {
        private readonly AppDbContext _context;

        public DashboardController(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Dashboard özet bilgileri: Aylık gelir/gider, bekleyen faturalar, yaklaşan işlemler
        /// </summary>
        [HttpGet("summary")]
        public async Task<ActionResult<DashboardSummaryDto>> GetSummary()
        {
            var now = DateTime.UtcNow;
            var startOfMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
            var endOfMonth = startOfMonth.AddMonths(1);

            // Aylık gelir (Sales invoices marked as Paid)
            var monthlyIncome = await _context.Invoices
                .Where(i => i.IsActive && i.Status != InvoiceStatus.Cancelled && i.Type == InvoiceType.Sales
                    && i.IssueDate >= startOfMonth && i.IssueDate < endOfMonth)
                .SumAsync(i => (decimal?)i.TotalAmount) ?? 0;

            // Aylık gider (Purchase invoices)
            var monthlyExpense = await _context.Invoices
                .Where(i => i.IsActive && i.Status != InvoiceStatus.Cancelled && i.Type == InvoiceType.Purchase
                    && i.IssueDate >= startOfMonth && i.IssueDate < endOfMonth)
                .SumAsync(i => (decimal?)i.TotalAmount) ?? 0;

            // Bekleyen fatura sayısı
            var pendingCount = await _context.Invoices
                .CountAsync(i => i.IsActive && i.Status == InvoiceStatus.Pending);

            // Gecikmiş fatura sayısı
            var overdueCount = await _context.Invoices
                .CountAsync(i => i.IsActive && i.Status == InvoiceStatus.Overdue);

            // Yaklaşan işlemler (beklenen faturalar)
            var upcomingInvoices = await _context.Invoices
                .Include(i => i.BusinessContact)
                .Include(i => i.Currency)
                .Where(i => i.IsActive && i.Status == InvoiceStatus.Pending && i.DueDate >= now)
                .OrderBy(i => i.DueDate)
                .Take(5)
                .Select(i => new UpcomingItemDto
                {
                    Title = i.BusinessContact.Name,
                    Date = i.DueDate.ToString("dd MMM yyyy"),
                    Amount = i.TotalAmount,
                    CurrencySymbol = i.Currency.Symbol,
                    Type = i.Type == InvoiceType.Sales ? "income" : "expense"
                })
                .ToListAsync();

            // Son faturalar
            var recentInvoices = await _context.Invoices
                .Include(i => i.BusinessContact)
                .Include(i => i.Currency)
                .Where(i => i.IsActive)
                .OrderByDescending(i => i.CreatedAt)
                .Take(5)
                .Select(i => new RecentInvoiceDto
                {
                    Id = i.Id,
                    InvoiceNumber = i.InvoiceNumber,
                    ContactName = i.BusinessContact.Name,
                    TotalAmount = i.TotalAmount,
                    CurrencyCode = i.Currency.Code,
                    Status = (byte)i.Status,
                    IssueDate = i.IssueDate
                })
                .ToListAsync();

            // Düşük stoklu ürünler (Physical ürünlerde stok < 10)
            var stockAlerts = await _context.Products
                .Where(p => p.IsActive && p.Type == ProductType.Physical && p.StockQuantity < 10)
                .OrderBy(p => p.StockQuantity)
                .Take(5)
                .Select(p => new StockAlertDto
                {
                    ProductId = p.Id,
                    ProductName = p.Name,
                    ProductCode = p.Code,
                    CurrentStock = p.StockQuantity,
                    MinStock = 10
                })
                .ToListAsync();

            // Vadesi geçmiş faturalar
            var overdueInvoices = await _context.Invoices
                .Include(i => i.BusinessContact)
                .Include(i => i.Currency)
                .Where(i => i.IsActive && i.Status == InvoiceStatus.Pending && i.DueDate < now)
                .OrderBy(i => i.DueDate)
                .Take(5)
                .Select(i => new OverdueInvoiceDto
                {
                    Id = i.Id,
                    InvoiceNumber = i.InvoiceNumber,
                    ContactName = i.BusinessContact.Name,
                    TotalAmount = i.TotalAmount,
                    CurrencyCode = i.Currency.Code,
                    DueDate = i.DueDate,
                    DaysOverdue = (int)(now - i.DueDate).TotalDays
                })
                .ToListAsync();

            var summary = new DashboardSummaryDto
            {
                MonthlyIncome = monthlyIncome,
                MonthlyExpense = monthlyExpense,
                PendingInvoiceCount = pendingCount,
                OverdueInvoiceCount = overdueCount,
                UpcomingItems = upcomingInvoices,
                RecentInvoices = recentInvoices,
                StockAlerts = stockAlerts,
                OverdueInvoices = overdueInvoices
            };

            return Ok(summary);
        }

        /// <summary>
        /// Son 6 aylık gelir/gider grafiği verileri
        /// </summary>
        [HttpGet("monthly-chart")]
        public async Task<ActionResult<MonthlyChartDto>> GetMonthlyChart()
        {
            var now = DateTime.UtcNow;
            var months = new List<MonthlyDataPoint>();
            var expenseMonths = new List<MonthlyDataPoint>();

            var monthNames = new[] { "", "Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara" };

            for (int i = 5; i >= 0; i--)
            {
                var month = now.AddMonths(-i);
                var startOfPeriod = new DateTime(month.Year, month.Month, 1, 0, 0, 0, DateTimeKind.Utc);
                var endOfPeriod = startOfPeriod.AddMonths(1);

                var income = await _context.Invoices
                    .Where(inv => inv.IsActive && inv.Status != InvoiceStatus.Cancelled && inv.Type == InvoiceType.Sales
                        && inv.IssueDate >= startOfPeriod && inv.IssueDate < endOfPeriod)
                    .SumAsync(inv => (decimal?)inv.TotalAmount) ?? 0;

                var expense = await _context.Invoices
                    .Where(inv => inv.IsActive && inv.Status != InvoiceStatus.Cancelled && inv.Type == InvoiceType.Purchase
                        && inv.IssueDate >= startOfPeriod && inv.IssueDate < endOfPeriod)
                    .SumAsync(inv => (decimal?)inv.TotalAmount) ?? 0;

                months.Add(new MonthlyDataPoint
                {
                    Month = month.Month,
                    MonthName = monthNames[month.Month],
                    Amount = income
                });

                expenseMonths.Add(new MonthlyDataPoint
                {
                    Month = month.Month,
                    MonthName = monthNames[month.Month],
                    Amount = expense
                });
            }

            return Ok(new MonthlyChartDto
            {
                IncomeData = months,
                ExpenseData = expenseMonths
            });
        }
    }
}
