using AccountingApp.API.Data;
using AccountingApp.API.DTOs;
using AccountingApp.API.Models;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AccountingApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin,Muhasebe")]
    public class BusinessContactsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public BusinessContactsController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<BusinessContactDto>>> GetContacts([FromQuery] byte? type)
        {
            var query = _context.BusinessContacts.Where(c => c.IsActive);

            if (type.HasValue)
            {
                query = query.Where(c => (byte)c.Type == type.Value);
            }

            var contacts = await query.OrderBy(c => c.Name).ToListAsync();
            return Ok(_mapper.Map<IEnumerable<BusinessContactDto>>(contacts));
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<BusinessContactDto>> GetContact(Guid id)
        {
            var contact = await _context.BusinessContacts
                .FirstOrDefaultAsync(c => c.Id == id && c.IsActive);

            if (contact == null) return NotFound();
            return Ok(_mapper.Map<BusinessContactDto>(contact));
        }

        [HttpPost]
        [Authorize]
        public async Task<ActionResult<BusinessContactDto>> PostContact(BusinessContactCreateDto dto)
        {
            var contact = _mapper.Map<BusinessContact>(dto);
            contact.CreatedAt = DateTime.UtcNow;

            _context.BusinessContacts.Add(contact);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetContact), new { id = contact.Id },
                _mapper.Map<BusinessContactDto>(contact));
        }

        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> PutContact(Guid id, BusinessContactCreateDto dto)
        {
            var contact = await _context.BusinessContacts.FindAsync(id);
            if (contact == null) return NotFound();

            _mapper.Map(dto, contact);
            contact.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> DeleteContact(Guid id)
        {
            var contact = await _context.BusinessContacts.FindAsync(id);
            if (contact == null) return NotFound();

            contact.IsActive = false;
            contact.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return NoContent();
        }
        [HttpGet("{id}/statement")]
        public async Task<ActionResult> GetStatement(Guid id)
        {
            var contact = await _context.BusinessContacts
                .FirstOrDefaultAsync(c => c.Id == id && c.IsActive);

            if (contact == null) return NotFound();

            var invoices = await _context.Invoices
                .Include(i => i.Currency)
                .Where(i => i.BusinessContactId == id && i.IsActive)
                .OrderByDescending(i => i.IssueDate)
                .Select(i => new {
                    i.Id, i.InvoiceNumber, Type = (byte)i.Type, Status = (byte)i.Status,
                    i.IssueDate, i.DueDate, i.TotalAmount,
                    CurrencyCode = i.Currency.Code
                })
                .ToListAsync();

            var transactions = await _context.Transactions
                .Where(t => t.BusinessContactId == id && t.IsActive)
                .OrderByDescending(t => t.Date)
                .Select(t => new {
                    t.Id, Type = (byte)t.Type, t.Amount,
                    CurrencyCode = t.Currency.Code,
                    TransactionDate = t.Date, t.Description, t.PaymentMethod
                })
                .ToListAsync();

            var totalInvoiced = invoices.Where(i => i.Status != (byte)InvoiceStatus.Cancelled).Sum(i => i.TotalAmount);
            var totalPaid = transactions.Sum(t => t.Amount);

            return Ok(new {
                contact = _mapper.Map<BusinessContactDto>(contact),
                invoices,
                transactions,
                totalInvoiced,
                totalPaid,
                balance = totalInvoiced - totalPaid
            });
        }
    }
}
