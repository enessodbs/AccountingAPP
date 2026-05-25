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
    public class PipelineStagesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PipelineStagesController(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Tüm pipeline aşamalarını listele (sıralı, fırsat sayısı ile)
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<PipelineStageDto>>> GetPipelineStages()
        {
            var stages = await _context.PipelineStages
                .Include(s => s.Opportunities)
                .Where(s => s.IsActive)
                .OrderBy(s => s.SortOrder)
                .Select(s => new PipelineStageDto
                {
                    Id = s.Id,
                    Name = s.Name,
                    SortOrder = s.SortOrder,
                    DefaultProbability = s.DefaultProbability,
                    IsActive = s.IsActive,
                    OpportunityCount = s.Opportunities.Count(o => o.IsActive)
                })
                .ToListAsync();

            return Ok(stages);
        }

        /// <summary>
        /// Yeni pipeline aşaması oluştur
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Admin,SatışYönetici")]
        public async Task<ActionResult<PipelineStageDto>> CreatePipelineStage(CreatePipelineStageDto dto)
        {
            // SortOrder verilmemişse en sona ekle
            if (dto.SortOrder <= 0)
            {
                var maxOrder = await _context.PipelineStages
                    .Where(s => s.IsActive)
                    .MaxAsync(s => (int?)s.SortOrder) ?? 0;
                dto.SortOrder = maxOrder + 1;
            }

            var stage = new PipelineStage
            {
                Name = dto.Name,
                SortOrder = dto.SortOrder,
                DefaultProbability = dto.DefaultProbability,
                CreatedAt = DateTime.UtcNow
            };

            _context.PipelineStages.Add(stage);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetPipelineStages), null,
                new { id = stage.Id, message = "Pipeline aşaması başarıyla oluşturuldu." });
        }

        /// <summary>
        /// Pipeline aşamasını güncelle
        /// </summary>
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,SatışYönetici")]
        public async Task<IActionResult> UpdatePipelineStage(int id, UpdatePipelineStageDto dto)
        {
            var stage = await _context.PipelineStages.FindAsync(id);
            if (stage == null || !stage.IsActive) return NotFound(new { message = "Pipeline aşaması bulunamadı." });

            stage.Name = dto.Name;
            stage.SortOrder = dto.SortOrder;
            stage.DefaultProbability = dto.DefaultProbability;
            stage.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Pipeline aşaması başarıyla güncellendi." });
        }

        /// <summary>
        /// Pipeline aşamasını sil (sadece fırsat yoksa)
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,SatışYönetici")]
        public async Task<IActionResult> DeletePipelineStage(int id)
        {
            var stage = await _context.PipelineStages
                .Include(s => s.Opportunities)
                .FirstOrDefaultAsync(s => s.Id == id && s.IsActive);

            if (stage == null) return NotFound(new { message = "Pipeline aşaması bulunamadı." });

            var activeOpportunities = stage.Opportunities.Count(o => o.IsActive);
            if (activeOpportunities > 0)
            {
                return BadRequest(new { message = $"Bu aşamada {activeOpportunities} aktif fırsat bulunmaktadır. Önce fırsatları başka aşamaya taşıyın." });
            }

            // Soft delete (BaseEntity pattern)
            stage.IsActive = false;
            stage.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Pipeline aşaması başarıyla silindi." });
        }

        /// <summary>
        /// Pipeline aşamalarını toplu sırala
        /// </summary>
        [HttpPut("reorder")]
        [Authorize(Roles = "Admin,SatışYönetici")]
        public async Task<IActionResult> ReorderStages(List<ReorderStageDto> dto)
        {
            var stageIds = dto.Select(d => d.Id).ToList();
            var stages = await _context.PipelineStages
                .Where(s => stageIds.Contains(s.Id) && s.IsActive)
                .ToListAsync();

            if (stages.Count != dto.Count)
            {
                return BadRequest(new { message = "Bazı pipeline aşamaları bulunamadı." });
            }

            foreach (var item in dto)
            {
                var stage = stages.First(s => s.Id == item.Id);
                stage.SortOrder = item.SortOrder;
                stage.UpdatedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Pipeline aşamaları başarıyla sıralandı." });
        }

        private Guid GetCurrentUserId()
        {
            return Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        }
    }
}
