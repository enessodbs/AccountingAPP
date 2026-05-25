using AccountingApp.API.Data;
using AccountingApp.API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AccountingApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin,Muhasebe")]
    public class ReportsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ReportsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Reports/profit-loss?year=2026
        [HttpGet("profit-loss")]
        public async Task<ActionResult> GetProfitLoss([FromQuery] int? year)
        {
            var y = year ?? DateTime.Now.Year;

            var invoices = await _context.Invoices
                .Where(i => i.IsActive && i.Status != InvoiceStatus.Cancelled && i.IssueDate.Year == y)
                .ToListAsync();

            var monthlyData = Enumerable.Range(1, 12).Select(month =>
            {
                var income = invoices.Where(i => (byte)i.Type == 1 && i.IssueDate.Month == month).Sum(i => i.TotalAmount);
                var expense = invoices.Where(i => (byte)i.Type == 2 && i.IssueDate.Month == month).Sum(i => i.TotalAmount);
                return new { month, income, expense, profit = income - expense };
            }).ToList();

            return Ok(new
            {
                year = y,
                totalIncome = monthlyData.Sum(m => m.income),
                totalExpense = monthlyData.Sum(m => m.expense),
                totalProfit = monthlyData.Sum(m => m.profit),
                monthly = monthlyData
            });
        }

        // GET: api/Reports/vat?year=2026
        [HttpGet("vat")]
        public async Task<ActionResult> GetVatReport([FromQuery] int? year)
        {
            var y = year ?? DateTime.Now.Year;

            var invoices = await _context.Invoices
                .Where(i => i.IsActive && i.Status != InvoiceStatus.Cancelled && i.IssueDate.Year == y)
                .ToListAsync();

            var monthlyData = Enumerable.Range(1, 12).Select(month =>
            {
                var collected = invoices.Where(i => (byte)i.Type == 1 && i.IssueDate.Month == month).Sum(i => i.TaxAmount);
                var paid = invoices.Where(i => (byte)i.Type == 2 && i.IssueDate.Month == month).Sum(i => i.TaxAmount);
                return new { month, collected, paid, net = collected - paid };
            }).ToList();

            return Ok(new
            {
                year = y,
                totalCollected = monthlyData.Sum(m => m.collected),
                totalPaid = monthlyData.Sum(m => m.paid),
                totalNet = monthlyData.Sum(m => m.net),
                monthly = monthlyData
            });
        }

        // GET: api/Reports/aging
        [HttpGet("aging")]
        public async Task<ActionResult> GetAgingReport()
        {
            var today = DateTime.UtcNow.Date;

            var overdueInvoices = await _context.Invoices
                .Include(i => i.BusinessContact)
                .Include(i => i.Currency)
                .Where(i => i.IsActive && i.DueDate < today && (byte)i.Status != 2 && (byte)i.Status != 5)
                .OrderBy(i => i.DueDate)
                .Select(i => new
                {
                    i.Id,
                    i.InvoiceNumber,
                    ContactName = i.BusinessContact.Name,
                    i.TotalAmount,
                    CurrencyCode = i.Currency.Code,
                    i.DueDate,
                    DaysOverdue = (today - i.DueDate).Days,
                    Type = (byte)i.Type
                })
                .ToListAsync();

            var aging0_30 = overdueInvoices.Where(i => i.DaysOverdue <= 30).Sum(i => i.TotalAmount);
            var aging31_60 = overdueInvoices.Where(i => i.DaysOverdue > 30 && i.DaysOverdue <= 60).Sum(i => i.TotalAmount);
            var aging61_90 = overdueInvoices.Where(i => i.DaysOverdue > 60 && i.DaysOverdue <= 90).Sum(i => i.TotalAmount);
            var aging90Plus = overdueInvoices.Where(i => i.DaysOverdue > 90).Sum(i => i.TotalAmount);

            return Ok(new
            {
                totalOverdue = overdueInvoices.Sum(i => i.TotalAmount),
                aging0_30,
                aging31_60,
                aging61_90,
                aging90Plus,
                invoices = overdueInvoices
            });
        }
    }
}
