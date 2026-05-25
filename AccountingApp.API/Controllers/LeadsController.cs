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
    [Authorize(Roles = "Admin,SatışYönetici,Satış,Pazarlama")]
    public class LeadsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public LeadsController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        /// <summary>
        /// Tüm lead'leri listele (rol bazlı filtreleme).
        /// Satış rolü sadece kendine atanmış lead'leri görür.
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<LeadDto>>> GetLeads(
            [FromQuery] byte? status,
            [FromQuery] byte? source,
            [FromQuery] byte? priority,
            [FromQuery] string? search)
        {
            var userId = GetCurrentUserId();
            var userRoles = GetCurrentUserRoles();

            var query = _context.Leads
                .Include(l => l.AssignedTo)
                .Include(l => l.CreatedBy)
                .Include(l => l.Currency)
                .Include(l => l.Activities)
                .Include(l => l.Tasks)
                .Where(l => l.IsActive);

            // Row-level security: Satış rolü sadece kendi lead'lerini görsün
            if (userRoles.Contains("Satış") && !userRoles.Contains("Admin") && !userRoles.Contains("SatışYönetici"))
            {
                query = query.Where(l => l.AssignedToId == userId || l.CreatedById == userId);
            }

            // Filtreler
            if (status.HasValue)
                query = query.Where(l => (byte)l.Status == status.Value);

            if (source.HasValue)
                query = query.Where(l => (byte)l.Source == source.Value);

            if (priority.HasValue)
                query = query.Where(l => (byte)l.Priority == priority.Value);

            if (!string.IsNullOrWhiteSpace(search))
            {
                var term = search.ToLower();
                query = query.Where(l =>
                    l.FirstName.ToLower().Contains(term) ||
                    l.LastName.ToLower().Contains(term) ||
                    (l.CompanyName != null && l.CompanyName.ToLower().Contains(term)) ||
                    (l.Email != null && l.Email.ToLower().Contains(term)));
            }

            var leads = await query
                .OrderByDescending(l => l.CreatedAt)
                .Select(l => new LeadDto
                {
                    Id = l.Id,
                    FirstName = l.FirstName,
                    LastName = l.LastName,
                    CompanyName = l.CompanyName,
                    Email = l.Email,
                    Phone = l.Phone,
                    Website = l.Website,
                    Status = (byte)l.Status,
                    Source = (byte)l.Source,
                    Priority = (byte)l.Priority,
                    AssignedToId = l.AssignedToId,
                    AssignedToName = l.AssignedTo != null ? l.AssignedTo.Username : null,
                    CreatedById = l.CreatedById,
                    CreatedByName = l.CreatedBy.Username,
                    ConvertedContactId = l.ConvertedContactId,
                    ConvertedOpportunityId = l.ConvertedOpportunityId,
                    ConvertedAt = l.ConvertedAt,
                    LostReason = l.LostReason,
                    EstimatedValue = l.EstimatedValue,
                    CurrencyId = l.CurrencyId,
                    CurrencyCode = l.Currency != null ? l.Currency.Code : null,
                    CurrencySymbol = l.Currency != null ? l.Currency.Symbol : null,
                    Notes = l.Notes,
                    Tags = l.Tags,
                    CreatedAt = l.CreatedAt,
                    UpdatedAt = l.UpdatedAt,
                    IsActive = l.IsActive,
                    ActivityCount = l.Activities.Count(a => a.IsActive),
                    TaskCount = l.Tasks.Count(t => t.IsActive)
                })
                .ToListAsync();

            return Ok(leads);
        }

        /// <summary>
        /// Lead detayı — aktiviteler ve görevlerle birlikte
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<LeadDto>> GetLead(Guid id)
        {
            var lead = await _context.Leads
                .Include(l => l.AssignedTo)
                .Include(l => l.CreatedBy)
                .Include(l => l.Currency)
                .Include(l => l.Activities)
                .Include(l => l.Tasks)
                .FirstOrDefaultAsync(l => l.Id == id && l.IsActive);

            if (lead == null) return NotFound(new { message = "Lead bulunamadı." });

            // Row-level check
            if (!CanAccessLead(lead))
                return Forbid();

            var dto = new LeadDto
            {
                Id = lead.Id,
                FirstName = lead.FirstName,
                LastName = lead.LastName,
                CompanyName = lead.CompanyName,
                Email = lead.Email,
                Phone = lead.Phone,
                Website = lead.Website,
                Status = (byte)lead.Status,
                Source = (byte)lead.Source,
                Priority = (byte)lead.Priority,
                AssignedToId = lead.AssignedToId,
                AssignedToName = lead.AssignedTo?.Username,
                CreatedById = lead.CreatedById,
                CreatedByName = lead.CreatedBy.Username,
                ConvertedContactId = lead.ConvertedContactId,
                ConvertedOpportunityId = lead.ConvertedOpportunityId,
                ConvertedAt = lead.ConvertedAt,
                LostReason = lead.LostReason,
                EstimatedValue = lead.EstimatedValue,
                CurrencyId = lead.CurrencyId,
                CurrencyCode = lead.Currency?.Code,
                CurrencySymbol = lead.Currency?.Symbol,
                Notes = lead.Notes,
                Tags = lead.Tags,
                CreatedAt = lead.CreatedAt,
                UpdatedAt = lead.UpdatedAt,
                IsActive = lead.IsActive,
                ActivityCount = lead.Activities.Count(a => a.IsActive),
                TaskCount = lead.Tasks.Count(t => t.IsActive)
            };

            return Ok(dto);
        }

        /// <summary>
        /// Yeni lead oluştur
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<LeadDto>> CreateLead(LeadCreateDto dto)
        {
            var userId = GetCurrentUserId();

            var lead = new Lead
            {
                Id = Guid.NewGuid(),
                FirstName = dto.FirstName,
                LastName = dto.LastName,
                CompanyName = dto.CompanyName,
                Email = dto.Email,
                Phone = dto.Phone,
                Website = dto.Website,
                Source = (LeadSource)dto.Source,
                Priority = (LeadPriority)dto.Priority,
                Status = LeadStatus.New,
                AssignedToId = dto.AssignedToId ?? userId,
                CreatedById = userId,
                EstimatedValue = dto.EstimatedValue,
                CurrencyId = dto.CurrencyId,
                Notes = dto.Notes,
                Tags = dto.Tags,
                CreatedAt = DateTime.UtcNow
            };

            _context.Leads.Add(lead);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetLead), new { id = lead.Id },
                new { id = lead.Id, message = "Lead başarıyla oluşturuldu." });
        }

        /// <summary>
        /// Lead güncelle
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateLead(Guid id, LeadUpdateDto dto)
        {
            var lead = await _context.Leads.FindAsync(id);
            if (lead == null || !lead.IsActive) return NotFound(new { message = "Lead bulunamadı." });

            if (!CanAccessLead(lead))
                return Forbid();

            // Dönüştürülmüş lead düzenlenemez
            if (lead.Status == LeadStatus.Converted)
                return BadRequest(new { message = "Dönüştürülmüş lead düzenlenemez." });

            lead.FirstName = dto.FirstName;
            lead.LastName = dto.LastName;
            lead.CompanyName = dto.CompanyName;
            lead.Email = dto.Email;
            lead.Phone = dto.Phone;
            lead.Website = dto.Website;
            lead.Source = (LeadSource)dto.Source;
            lead.Priority = (LeadPriority)dto.Priority;
            lead.AssignedToId = dto.AssignedToId;
            lead.EstimatedValue = dto.EstimatedValue;
            lead.CurrencyId = dto.CurrencyId;
            lead.Notes = dto.Notes;
            lead.Tags = dto.Tags;
            lead.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Lead başarıyla güncellendi." });
        }

        /// <summary>
        /// Lead sil (soft delete)
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,SatışYönetici")]
        public async Task<IActionResult> DeleteLead(Guid id)
        {
            var lead = await _context.Leads.FindAsync(id);
            if (lead == null) return NotFound(new { message = "Lead bulunamadı." });

            lead.IsActive = false;
            lead.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Lead başarıyla silindi." });
        }

        /// <summary>
        /// Lead'i başka kullanıcıya ata
        /// </summary>
        [HttpPut("{id}/assign")]
        [Authorize(Roles = "Admin,SatışYönetici")]
        public async Task<IActionResult> AssignLead(Guid id, LeadAssignDto dto)
        {
            var lead = await _context.Leads.FindAsync(id);
            if (lead == null || !lead.IsActive) return NotFound(new { message = "Lead bulunamadı." });

            var user = await _context.Users.FindAsync(dto.AssignedToId);
            if (user == null || !user.IsActive) return BadRequest(new { message = "Kullanıcı bulunamadı." });

            lead.AssignedToId = dto.AssignedToId;
            lead.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = $"Lead '{user.Username}' kullanıcısına atandı." });
        }

        /// <summary>
        /// Lead durumunu değiştir
        /// </summary>
        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateLeadStatus(Guid id, LeadStatusUpdateDto dto)
        {
            var lead = await _context.Leads.FindAsync(id);
            if (lead == null || !lead.IsActive) return NotFound(new { message = "Lead bulunamadı." });

            if (!CanAccessLead(lead))
                return Forbid();

            // Dönüştürülmüş lead'in durumu değiştirilemez
            if (lead.Status == LeadStatus.Converted)
                return BadRequest(new { message = "Dönüştürülmüş lead'in durumu değiştirilemez." });

            lead.Status = (LeadStatus)dto.Status;

            if (lead.Status == LeadStatus.Lost)
            {
                lead.LostReason = dto.LostReason;
            }

            lead.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Lead durumu güncellendi.", status = dto.Status });
        }

        /// <summary>
        /// Lead'i müşteriye (BusinessContact) ve opsiyonel olarak fırsata (Opportunity) dönüştür
        /// </summary>
        [HttpPost("{id}/convert")]
        [Authorize(Roles = "Admin,SatışYönetici,Satış")]
        public async Task<ActionResult<LeadConvertResultDto>> ConvertLead(Guid id, LeadConvertDto dto)
        {
            var lead = await _context.Leads
                .Include(l => l.Currency)
                .FirstOrDefaultAsync(l => l.Id == id && l.IsActive);

            if (lead == null) return NotFound(new { message = "Lead bulunamadı." });

            if (lead.Status == LeadStatus.Converted)
                return BadRequest(new { message = "Bu lead zaten dönüştürülmüş." });

            var userId = GetCurrentUserId();

            // 1. BusinessContact oluştur
            var contact = new BusinessContact
            {
                Id = Guid.NewGuid(),
                Type = ContactType.Customer,
                Name = string.IsNullOrWhiteSpace(lead.CompanyName)
                    ? $"{lead.FirstName} {lead.LastName}"
                    : lead.CompanyName,
                Email = lead.Email ?? string.Empty,
                Phone = lead.Phone ?? string.Empty,
                Address = string.Empty,
                TaxNumber = string.Empty,
                TaxOffice = string.Empty,
                CreatedAt = DateTime.UtcNow
            };

            _context.BusinessContacts.Add(contact);

            // 2. Opsiyonel: Opportunity oluştur
            Guid? opportunityId = null;
            if (dto.CreateOpportunity)
            {
                var defaultStage = await _context.PipelineStages
                    .OrderBy(s => s.SortOrder)
                    .FirstOrDefaultAsync(s => s.IsActive);

                var opportunity = new Opportunity
                {
                    Id = Guid.NewGuid(),
                    Title = dto.OpportunityTitle ?? $"{contact.Name} — Fırsat",
                    ContactId = contact.Id,
                    OwnerId = userId,
                    StageId = dto.StageId ?? defaultStage?.Id ?? 1,
                    Amount = dto.OpportunityAmount ?? lead.EstimatedValue ?? 0,
                    CurrencyId = dto.CurrencyId ?? lead.CurrencyId ?? 1,
                    Probability = defaultStage?.DefaultProbability ?? 10,
                    Status = OpportunityStatus.Open,
                    SourceLeadId = lead.Id,
                    CreatedAt = DateTime.UtcNow
                };
                opportunity.CalculateWeightedAmount();

                _context.Opportunities.Add(opportunity);
                opportunityId = opportunity.Id;
                lead.ConvertedOpportunityId = opportunity.Id;
            }

            // 3. Lead'i güncelle
            lead.Status = LeadStatus.Converted;
            lead.ConvertedContactId = contact.Id;
            lead.ConvertedAt = DateTime.UtcNow;
            lead.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return Ok(new LeadConvertResultDto
            {
                ContactId = contact.Id,
                OpportunityId = opportunityId,
                Message = "Lead başarıyla müşteriye dönüştürüldü."
            });
        }

        /// <summary>
        /// Lead istatistikleri (Dashboard için)
        /// </summary>
        [HttpGet("stats")]
        public async Task<ActionResult> GetLeadStats()
        {
            var userId = GetCurrentUserId();
            var userRoles = GetCurrentUserRoles();

            var query = _context.Leads.Where(l => l.IsActive);

            if (userRoles.Contains("Satış") && !userRoles.Contains("Admin") && !userRoles.Contains("SatışYönetici"))
            {
                query = query.Where(l => l.AssignedToId == userId || l.CreatedById == userId);
            }

            var totalLeads = await query.CountAsync();
            var byStatus = await query.GroupBy(l => l.Status)
                .Select(g => new { Status = (byte)g.Key, Count = g.Count() })
                .ToListAsync();
            var bySource = await query.GroupBy(l => l.Source)
                .Select(g => new { Source = (byte)g.Key, Count = g.Count() })
                .ToListAsync();
            var thisMonthNew = await query
                .Where(l => l.CreatedAt.Month == DateTime.UtcNow.Month && l.CreatedAt.Year == DateTime.UtcNow.Year)
                .CountAsync();
            var totalEstimatedValue = await query
                .Where(l => l.EstimatedValue.HasValue)
                .SumAsync(l => l.EstimatedValue ?? 0);

            return Ok(new
            {
                totalLeads,
                thisMonthNew,
                totalEstimatedValue,
                byStatus,
                bySource
            });
        }

        // =========== Helper Methods ===========

        private Guid GetCurrentUserId()
        {
            return Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        }

        private List<string> GetCurrentUserRoles()
        {
            return User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();
        }

        private bool CanAccessLead(Lead lead)
        {
            var userRoles = GetCurrentUserRoles();
            if (userRoles.Contains("Admin") || userRoles.Contains("SatışYönetici"))
                return true;

            var userId = GetCurrentUserId();
            return lead.AssignedToId == userId || lead.CreatedById == userId;
        }
    }
}
