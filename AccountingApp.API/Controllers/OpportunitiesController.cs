using AccountingApp.API.Data;
using AccountingApp.API.DTOs;
using AccountingApp.API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace AccountingApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin,SatışYönetici,Satış,Pazarlama")]
    public class OpportunitiesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public OpportunitiesController(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Tüm aktif fırsatları listele (filtreli)
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<OpportunityListDto>>> GetOpportunities(
            [FromQuery] int? stageId,
            [FromQuery] Guid? contactId,
            [FromQuery] Guid? ownerId,
            [FromQuery] byte? status,
            [FromQuery] string? search)
        {
            var query = _context.Opportunities
                .Include(o => o.Stage)
                .Include(o => o.Contact)
                .Include(o => o.Owner)
                .Include(o => o.SourceLead)
                .Where(o => o.IsActive);

            if (stageId.HasValue)
                query = query.Where(o => o.StageId == stageId.Value);

            if (contactId.HasValue)
                query = query.Where(o => o.ContactId == contactId.Value);

            if (ownerId.HasValue)
                query = query.Where(o => o.OwnerId == ownerId.Value);

            if (status.HasValue)
                query = query.Where(o => (byte)o.Status == status.Value);

            if (!string.IsNullOrWhiteSpace(search))
            {
                var term = search.ToLower();
                query = query.Where(o =>
                    o.Title.ToLower().Contains(term) ||
                    o.Contact.Name.ToLower().Contains(term) ||
                    (o.Description != null && o.Description.ToLower().Contains(term)));
            }

            var opportunities = await query
                .OrderByDescending(o => o.CreatedAt)
                .Select(o => new OpportunityListDto
                {
                    Id = o.Id,
                    Title = o.Title,
                    Amount = o.Amount,
                    Probability = o.Probability,
                    WeightedAmount = o.WeightedAmount,
                    ExpectedCloseDate = o.ExpectedCloseDate,
                    ContactId = o.ContactId,
                    ContactName = o.Contact.Name,
                    OwnerId = o.OwnerId,
                    OwnerName = o.Owner.Username,
                    StageId = o.StageId,
                    StageName = o.Stage.Name,
                    SourceLeadId = o.SourceLeadId,
                    SourceLeadCompany = o.SourceLead != null ? o.SourceLead.CompanyName : null,
                    Status = (byte)o.Status,
                    CreatedAt = o.CreatedAt
                })
                .ToListAsync();

            return Ok(opportunities);
        }

        /// <summary>
        /// Fırsat detayı — aktiviteler ve görevlerle birlikte
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<OpportunityDetailDto>> GetOpportunity(Guid id)
        {
            var opportunity = await _context.Opportunities
                .Include(o => o.Stage)
                .Include(o => o.Contact)
                .Include(o => o.Owner)
                .Include(o => o.SourceLead)
                .Include(o => o.Activities)
                .Include(o => o.Tasks)
                .FirstOrDefaultAsync(o => o.Id == id && o.IsActive);

            if (opportunity == null) return NotFound(new { message = "Fırsat bulunamadı." });

            var dto = new OpportunityDetailDto
            {
                Id = opportunity.Id,
                Title = opportunity.Title,
                Description = opportunity.Description,
                Amount = opportunity.Amount,
                Probability = opportunity.Probability,
                WeightedAmount = opportunity.WeightedAmount,
                ExpectedCloseDate = opportunity.ExpectedCloseDate,
                ActualCloseDate = opportunity.ActualCloseDate,
                Status = (byte)opportunity.Status,
                LostReason = opportunity.LostReason,
                ContactId = opportunity.ContactId,
                ContactName = opportunity.Contact.Name,
                OwnerId = opportunity.OwnerId,
                OwnerName = opportunity.Owner.Username,
                StageId = opportunity.StageId,
                StageName = opportunity.Stage.Name,
                SourceLeadId = opportunity.SourceLeadId,
                SourceLeadCompany = opportunity.SourceLead?.CompanyName,
                CurrencyId = opportunity.CurrencyId,
                ActivityCount = opportunity.Activities.Count(a => a.IsActive),
                TaskCount = opportunity.Tasks.Count(t => t.IsActive),
                CreatedAt = opportunity.CreatedAt,
                UpdatedAt = opportunity.UpdatedAt,
                IsActive = opportunity.IsActive
            };

            return Ok(dto);
        }

        /// <summary>
        /// Pipeline Board — Aşamalara göre gruplanmış fırsatlar
        /// </summary>
        [HttpGet("board")]
        public async Task<ActionResult<IEnumerable<PipelineBoardColumnDto>>> GetBoard()
        {
            var stages = await _context.PipelineStages
                .Include(s => s.Opportunities.Where(o => o.IsActive))
                    .ThenInclude(o => o.Contact)
                .Include(s => s.Opportunities.Where(o => o.IsActive))
                    .ThenInclude(o => o.Owner)
                .Include(s => s.Opportunities.Where(o => o.IsActive))
                    .ThenInclude(o => o.SourceLead)
                .Where(s => s.IsActive)
                .OrderBy(s => s.SortOrder)
                .ToListAsync();

            var board = stages.Select(s => new PipelineBoardColumnDto
            {
                StageId = s.Id,
                StageName = s.Name,
                StageOrder = s.SortOrder,
                DefaultProbability = s.DefaultProbability,
                Opportunities = s.Opportunities
                    .OrderByDescending(o => o.CreatedAt)
                    .Select(o => new OpportunityListDto
                    {
                        Id = o.Id,
                        Title = o.Title,
                        Amount = o.Amount,
                        Probability = o.Probability,
                        WeightedAmount = o.WeightedAmount,
                        ExpectedCloseDate = o.ExpectedCloseDate,
                        ContactId = o.ContactId,
                        ContactName = o.Contact.Name,
                        OwnerId = o.OwnerId,
                        OwnerName = o.Owner.Username,
                        StageId = o.StageId,
                        StageName = s.Name,
                        SourceLeadId = o.SourceLeadId,
                        SourceLeadCompany = o.SourceLead?.CompanyName,
                        Status = (byte)o.Status,
                        CreatedAt = o.CreatedAt
                    })
                    .ToList()
            }).ToList();

            return Ok(board);
        }

        /// <summary>
        /// Yeni fırsat oluştur
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<OpportunityDetailDto>> CreateOpportunity(CreateOpportunityDto dto)
        {
            var userId = GetCurrentUserId();

            // Contact kontrolü
            var contact = await _context.BusinessContacts.FindAsync(dto.ContactId);
            if (contact == null || !contact.IsActive)
                return BadRequest(new { message = "Geçersiz müşteri." });

            // Stage kontrolü
            var stage = await _context.PipelineStages.FindAsync(dto.StageId);
            if (stage == null || !stage.IsActive)
                return BadRequest(new { message = "Geçersiz pipeline aşaması." });

            var opportunity = new Opportunity
            {
                Id = Guid.NewGuid(),
                Title = dto.Title,
                Description = dto.Description,
                Amount = dto.Amount,
                Probability = dto.Probability,
                ContactId = dto.ContactId,
                OwnerId = userId,
                StageId = dto.StageId,
                SourceLeadId = dto.SourceLeadId,
                CurrencyId = dto.CurrencyId,
                ExpectedCloseDate = dto.ExpectedCloseDate,
                Status = OpportunityStatus.Open,
                CreatedAt = DateTime.UtcNow
            };
            opportunity.CalculateWeightedAmount();

            _context.Opportunities.Add(opportunity);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetOpportunity), new { id = opportunity.Id },
                new { id = opportunity.Id, message = "Fırsat başarıyla oluşturuldu." });
        }

        /// <summary>
        /// Fırsat güncelle
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateOpportunity(Guid id, UpdateOpportunityDto dto)
        {
            var opportunity = await _context.Opportunities.FindAsync(id);
            if (opportunity == null || !opportunity.IsActive) return NotFound(new { message = "Fırsat bulunamadı." });

            opportunity.Title = dto.Title;
            opportunity.Description = dto.Description;
            opportunity.Amount = dto.Amount;
            opportunity.Probability = dto.Probability;
            opportunity.ExpectedCloseDate = dto.ExpectedCloseDate;
            opportunity.ContactId = dto.ContactId;
            opportunity.StageId = dto.StageId;
            opportunity.SourceLeadId = dto.SourceLeadId;
            opportunity.OwnerId = dto.OwnerId;
            opportunity.CurrencyId = dto.CurrencyId;
            opportunity.UpdatedAt = DateTime.UtcNow;
            opportunity.CalculateWeightedAmount();

            await _context.SaveChangesAsync();
            return Ok(new { message = "Fırsat başarıyla güncellendi." });
        }

        /// <summary>
        /// Fırsatı farklı aşamaya taşı
        /// </summary>
        [HttpPut("{id}/move")]
        public async Task<IActionResult> MoveOpportunity(Guid id, MoveOpportunityDto dto)
        {
            var opportunity = await _context.Opportunities.FindAsync(id);
            if (opportunity == null || !opportunity.IsActive) return NotFound(new { message = "Fırsat bulunamadı." });

            var stage = await _context.PipelineStages.FindAsync(dto.StageId);
            if (stage == null || !stage.IsActive) return BadRequest(new { message = "Geçersiz pipeline aşaması." });

            opportunity.StageId = dto.StageId;

            if (dto.Probability.HasValue)
            {
                opportunity.Probability = dto.Probability.Value;
            }

            opportunity.CalculateWeightedAmount();
            opportunity.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return Ok(new { message = $"Fırsat '{stage.Name}' aşamasına taşındı." });
        }

        /// <summary>
        /// Fırsatı kapat (Kazanıldı / Kaybedildi)
        /// </summary>
        [HttpPut("{id}/close")]
        public async Task<IActionResult> CloseOpportunity(Guid id, CloseOpportunityDto dto)
        {
            var opportunity = await _context.Opportunities.FindAsync(id);
            if (opportunity == null || !opportunity.IsActive) return NotFound(new { message = "Fırsat bulunamadı." });

            if (opportunity.Status != OpportunityStatus.Open)
                return BadRequest(new { message = "Bu fırsat zaten kapatılmış." });

            opportunity.ActualCloseDate = DateTime.UtcNow;
            opportunity.UpdatedAt = DateTime.UtcNow;

            if (dto.IsWon)
            {
                opportunity.Status = OpportunityStatus.Won;
            }
            else
            {
                opportunity.Status = OpportunityStatus.Lost;
                opportunity.LostReason = dto.LostReason;
            }

            await _context.SaveChangesAsync();

            var statusText = dto.IsWon ? "kazanıldı" : "kaybedildi";
            return Ok(new { message = $"Fırsat başarıyla {statusText} olarak kapatıldı." });
        }

        /// <summary>
        /// Fırsat sil (soft delete)
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,SatışYönetici")]
        public async Task<IActionResult> DeleteOpportunity(Guid id)
        {
            var opportunity = await _context.Opportunities.FindAsync(id);
            if (opportunity == null) return NotFound(new { message = "Fırsat bulunamadı." });

            opportunity.IsActive = false;
            opportunity.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Fırsat başarıyla silindi." });
        }

        /// <summary>
        /// Fırsat istatistikleri (Dashboard için)
        /// </summary>
        [HttpGet("stats")]
        public async Task<ActionResult> GetOpportunityStats()
        {
            var query = _context.Opportunities
                .Include(o => o.Stage)
                .Where(o => o.IsActive);

            var totalCount = await query.CountAsync();
            var totalAmount = await query.SumAsync(o => o.Amount);
            var avgProbability = totalCount > 0
                ? await query.AverageAsync(o => (double)o.Probability)
                : 0;
            var wonCount = await query.CountAsync(o => o.Status == OpportunityStatus.Won);
            var lostCount = await query.CountAsync(o => o.Status == OpportunityStatus.Lost);

            var byStage = await query
                .GroupBy(o => new { o.Stage.Name, o.StageId })
                .Select(g => new
                {
                    StageId = g.Key.StageId,
                    StageName = g.Key.Name,
                    Count = g.Count(),
                    TotalAmount = g.Sum(o => o.Amount)
                })
                .ToListAsync();

            return Ok(new
            {
                totalCount,
                totalAmount,
                avgProbability = Math.Round(avgProbability, 1),
                wonCount,
                lostCount,
                byStage
            });
        }

        // =========== Helper Methods ===========

        private Guid GetCurrentUserId()
        {
            return Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        }
    }
}
