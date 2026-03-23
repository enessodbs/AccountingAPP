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
    public class StockMovementsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public StockMovementsController(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Belirli bir ürünün stok hareketleri
        /// </summary>
        [HttpGet("product/{productId}")]
        public async Task<ActionResult<IEnumerable<StockMovement>>> GetByProduct(int productId)
        {
            var movements = await _context.StockMovements
                .Include(sm => sm.Product)
                .Include(sm => sm.Invoice)
                .Where(sm => sm.ProductId == productId && sm.IsActive)
                .OrderByDescending(sm => sm.Date)
                .ToListAsync();

            return Ok(movements);
        }

        /// <summary>
        /// Manuel stok hareketi oluşturma (fatura dışı giriş/çıkış)
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> PostStockMovement([FromBody] StockMovementCreateRequest request)
        {
            var product = await _context.Products.FindAsync(request.ProductId);
            if (product == null) return NotFound("Ürün bulunamadı.");

            if (product.Type == ProductType.Service)
                return BadRequest("Hizmet türündeki ürünler için stok hareketi oluşturulamaz.");

            var movement = new StockMovement
            {
                ProductId = request.ProductId,
                Quantity = request.Quantity,
                MovementType = (MovementType)request.MovementType,
                Date = DateTime.UtcNow,
                Description = request.Description ?? string.Empty,
                CreatedAt = DateTime.UtcNow
            };

            // Stok güncelle
            if (movement.MovementType == MovementType.In)
            {
                product.StockQuantity += request.Quantity;
            }
            else
            {
                if (product.StockQuantity < request.Quantity)
                    return BadRequest("Yeterli stok yok.");
                product.StockQuantity -= request.Quantity;
            }

            product.UpdatedAt = DateTime.UtcNow;
            _context.StockMovements.Add(movement);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Stok hareketi başarıyla oluşturuldu.", newStock = product.StockQuantity });
        }
    }

    public class StockMovementCreateRequest
    {
        public int ProductId { get; set; }
        public decimal Quantity { get; set; }
        public byte MovementType { get; set; } // 1: In, 2: Out
        public string? Description { get; set; }
    }
}
