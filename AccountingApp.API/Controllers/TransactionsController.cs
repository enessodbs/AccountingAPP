using AccountingApp.API.Data;
using AccountingApp.API.DTOs;
using AccountingApp.API.Models;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace AccountingApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin,Muhasebe")]
    public class TransactionsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public TransactionsController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // GET: api/Transactions
        [HttpGet]
        public async Task<ActionResult<IEnumerable<TransactionDto>>> GetTransactions([FromQuery] byte? type)
        {
            var query = _context.Transactions
                .Include(t => t.BusinessContact)
                .Include(t => t.Invoice)
                .Include(t => t.Currency)
                .Where(t => t.IsActive);

            if (type.HasValue)
            {
                query = query.Where(t => (byte)t.Type == type.Value);
            }

            var transactions = await query.OrderByDescending(t => t.Date).ToListAsync();
            return Ok(_mapper.Map<IEnumerable<TransactionDto>>(transactions));
        }

        // GET: api/Transactions/5
        [HttpGet("{id}")]
        public async Task<ActionResult<TransactionDto>> GetTransaction(Guid id)
        {
            var transaction = await _context.Transactions
                .Include(t => t.BusinessContact)
                .Include(t => t.Invoice)
                .Include(t => t.Currency)
                .FirstOrDefaultAsync(t => t.Id == id && t.IsActive);

            if (transaction == null) return NotFound();

            return Ok(_mapper.Map<TransactionDto>(transaction));
        }

        // POST: api/Transactions
        [HttpPost]
        public async Task<ActionResult<TransactionDto>> PostTransaction(TransactionCreateDto dto)
        {
            var transaction = _mapper.Map<Transaction>(dto);
            transaction.CreatedAt = DateTime.UtcNow;

            // Get current user ID from JWT
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (Guid.TryParse(userIdClaim, out var userId))
            {
                transaction.CreatedById = userId;
            }

            _context.Transactions.Add(transaction);
            await _context.SaveChangesAsync();

            // Reload with related entities
            await _context.Entry(transaction).Reference(t => t.BusinessContact).LoadAsync();
            await _context.Entry(transaction).Reference(t => t.Currency).LoadAsync();
            if (transaction.InvoiceId.HasValue)
            {
                await _context.Entry(transaction).Reference(t => t.Invoice).LoadAsync();
            }

            return CreatedAtAction(nameof(GetTransaction), new { id = transaction.Id },
                _mapper.Map<TransactionDto>(transaction));
        }

        // DELETE: api/Transactions/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTransaction(Guid id)
        {
            var transaction = await _context.Transactions.FindAsync(id);
            if (transaction == null) return NotFound();

            transaction.IsActive = false;
            transaction.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
