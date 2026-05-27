using AccountingApp.API.Data;
using AccountingApp.API.Models;
using AccountingApp.API.DTOs;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace AccountingApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class InvoicesController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public InvoicesController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // GET: api/Invoices?type=1&status=5&fromDate=2026-01-01&toDate=2026-01-31&excludeCancelled=true
        [HttpGet]
        public async Task<ActionResult<IEnumerable<InvoiceListDto>>> GetInvoices(
            [FromQuery] byte? type,
            [FromQuery] byte? status,
            [FromQuery] DateTime? fromDate,
            [FromQuery] DateTime? toDate,
            [FromQuery] bool excludeCancelled = false)
        {
            var query = _context.Invoices
                .Include(i => i.BusinessContact)
                .Include(i => i.Currency)
                .Where(i => i.IsActive);

            if (excludeCancelled)
            {
                query = query.Where(i => i.Status != InvoiceStatus.Cancelled);
            }

            if (type.HasValue)
            {
                query = query.Where(i => (byte)i.Type == type.Value);
            }

            if (status.HasValue)
            {
                query = query.Where(i => (byte)i.Status == status.Value);
            }

            if (fromDate.HasValue)
            {
                var from = fromDate.Value.Date;
                query = query.Where(i => i.IssueDate >= from);
            }

            if (toDate.HasValue)
            {
                var toExclusive = toDate.Value.Date.AddDays(1);
                query = query.Where(i => i.IssueDate < toExclusive);
            }

            var invoices = await query.OrderByDescending(i => i.IssueDate).ToListAsync();
            return Ok(_mapper.Map<IEnumerable<InvoiceListDto>>(invoices));
        }

        // GET: api/Invoices/5
        [HttpGet("{id}")]
        public async Task<ActionResult<InvoiceDetailDto>> GetInvoice(Guid id)
        {
            var invoice = await _context.Invoices
                .Include(i => i.BusinessContact)
                .Include(i => i.Currency)
                .Include(i => i.InvoiceLines)
                    .ThenInclude(l => l.Product)
                .FirstOrDefaultAsync(i => i.Id == id && i.IsActive);

            if (invoice == null)
            {
                return NotFound();
            }

            return Ok(_mapper.Map<InvoiceDetailDto>(invoice));
        }

        // POST: api/Invoices
        [HttpPost]
        [Authorize(Roles = "Admin,Muhasebe")]
        public async Task<ActionResult<InvoiceDetailDto>> PostInvoice(InvoiceCreateDto invoiceDto)
        {
            var invoice = _mapper.Map<Invoice>(invoiceDto);
            
            // Generate a simple Invoice Number if not provided
            if (string.IsNullOrEmpty(invoice.InvoiceNumber))
            {
                invoice.InvoiceNumber = $"INV-{DateTime.Now:yyyyMMdd}-{Guid.NewGuid().ToString().Substring(0, 4).ToUpper()}";
            }

            // Set initial status based on invoice type
            if (invoiceDto.Status.HasValue)
            {
                invoice.Status = (InvoiceStatus)invoiceDto.Status.Value;
            }
            else
            {
                // Purchase (Gelen) → Pending (Ödenmemiş), Sales (Giden) → ToBeIssued (Kesilecek)
                invoice.Status = invoice.Type == InvoiceType.Purchase 
                    ? InvoiceStatus.Pending 
                    : InvoiceStatus.ToBeIssued;
            }
            
            // Calculate totals from lines
            decimal totalTax = 0;
            decimal subTotal = 0;

            if (invoice.InvoiceLines != null)
            {
                foreach (var line in invoice.InvoiceLines)
                {
                    // Calculate single line total
                    var lineSub = line.Quantity * line.UnitPrice;
                    var lineTax = lineSub * (line.TaxRate / 100);
                    
                    line.LineTotal = lineSub + lineTax;
                    
                    subTotal += lineSub;
                    totalTax += lineTax;
                }
            }

            invoice.TaxAmount = totalTax;
            invoice.TotalAmount = subTotal + totalTax;

            // Get current user ID from JWT token
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (Guid.TryParse(userIdClaim, out var userId))
            {
                invoice.CreatedById = userId;
            }

            _context.Invoices.Add(invoice);
            await _context.SaveChangesAsync();

            return await GetInvoice(invoice.Id);
        }

        // PUT: api/Invoices/5/status
        [HttpPut("{id}/status")]
        [Authorize(Roles = "Admin,Muhasebe")]
        public async Task<IActionResult> UpdateInvoiceStatus(Guid id, [FromBody] byte status)
        {
            var invoice = await _context.Invoices.FindAsync(id);
            if (invoice == null || !invoice.IsActive)
            {
                return NotFound();
            }

            invoice.Status = (InvoiceStatus)status;
            invoice.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/Invoices/5
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,Muhasebe")]
        public async Task<IActionResult> DeleteInvoice(Guid id)
        {
            var invoice = await _context.Invoices.FindAsync(id);
            if (invoice == null)
            {
                return NotFound();
            }

            invoice.IsActive = false; // Soft delete instead of Cancel since Status covers business logic
            invoice.UpdatedAt = DateTime.UtcNow;
            
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
