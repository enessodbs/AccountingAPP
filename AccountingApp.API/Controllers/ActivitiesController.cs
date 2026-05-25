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
    public class ActivitiesController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public ActivitiesController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        /// <summary>
        /// Aktiviteleri listele (lead/fırsat/contact bazlı filtre)
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ActivityDto>>> GetActivities(
            [FromQuery] Guid? leadId,
            [FromQuery] Guid? opportunityId,
            [FromQuery] Guid? contactId,
            [FromQuery] byte? type)
        {
            var query = _context.Activities
                .Include(a => a.PerformedBy)
                .Include(a => a.Lead)
                .Include(a => a.Opportunity)
                .Include(a => a.Contact)
                .Where(a => a.IsActive);

            if (leadId.HasValue)
                query = query.Where(a => a.LeadId == leadId.Value);

            if (opportunityId.HasValue)
                query = query.Where(a => a.OpportunityId == opportunityId.Value);

            if (contactId.HasValue)
                query = query.Where(a => a.ContactId == contactId.Value);

            if (type.HasValue)
                query = query.Where(a => (byte)a.Type == type.Value);

            var activities = await query
                .OrderByDescending(a => a.ActivityDate)
                .Select(a => new ActivityDto
                {
                    Id = a.Id,
                    Type = (byte)a.Type,
                    Subject = a.Subject,
                    Description = a.Description,
                    ActivityDate = a.ActivityDate,
                    DurationMinutes = a.DurationMinutes,
                    PerformedById = a.PerformedById,
                    PerformedByName = a.PerformedBy.Username,
                    LeadId = a.LeadId,
                    LeadName = a.Lead != null ? a.Lead.FirstName + " " + a.Lead.LastName : null,
                    OpportunityId = a.OpportunityId,
                    OpportunityTitle = a.Opportunity != null ? a.Opportunity.Title : null,
                    ContactId = a.ContactId,
                    ContactName = a.Contact != null ? a.Contact.Name : null,
                    CreatedAt = a.CreatedAt,
                    IsActive = a.IsActive
                })
                .ToListAsync();

            return Ok(activities);
        }

        /// <summary>
        /// Tekil aktivite detayı
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<ActivityDto>> GetActivity(Guid id)
        {
            var activity = await _context.Activities
                .Include(a => a.PerformedBy)
                .Include(a => a.Lead)
                .Include(a => a.Opportunity)
                .Include(a => a.Contact)
                .FirstOrDefaultAsync(a => a.Id == id && a.IsActive);

            if (activity == null) return NotFound(new { message = "Aktivite bulunamadı." });

            var dto = new ActivityDto
            {
                Id = activity.Id,
                Type = (byte)activity.Type,
                Subject = activity.Subject,
                Description = activity.Description,
                ActivityDate = activity.ActivityDate,
                DurationMinutes = activity.DurationMinutes,
                PerformedById = activity.PerformedById,
                PerformedByName = activity.PerformedBy.Username,
                LeadId = activity.LeadId,
                LeadName = activity.Lead != null ? $"{activity.Lead.FirstName} {activity.Lead.LastName}" : null,
                OpportunityId = activity.OpportunityId,
                OpportunityTitle = activity.Opportunity?.Title,
                ContactId = activity.ContactId,
                ContactName = activity.Contact?.Name,
                CreatedAt = activity.CreatedAt,
                IsActive = activity.IsActive
            };

            return Ok(dto);
        }

        /// <summary>
        /// Yeni aktivite oluştur
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ActivityDto>> CreateActivity(ActivityCreateDto dto)
        {
            // En az bir referans olmalı
            if (!dto.LeadId.HasValue && !dto.OpportunityId.HasValue && !dto.ContactId.HasValue)
            {
                return BadRequest(new { message = "Aktivite en az bir Lead, Fırsat veya Müşteriye bağlı olmalıdır." });
            }

            var userId = GetCurrentUserId();

            var activity = new Activity
            {
                Id = Guid.NewGuid(),
                Type = (ActivityType)dto.Type,
                Subject = dto.Subject,
                Description = dto.Description,
                ActivityDate = dto.ActivityDate,
                DurationMinutes = dto.DurationMinutes,
                PerformedById = userId,
                LeadId = dto.LeadId,
                OpportunityId = dto.OpportunityId,
                ContactId = dto.ContactId,
                CreatedAt = DateTime.UtcNow
            };

            _context.Activities.Add(activity);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetActivity), new { id = activity.Id },
                new { id = activity.Id, message = "Aktivite başarıyla oluşturuldu." });
        }

        /// <summary>
        /// Aktivite güncelle
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateActivity(Guid id, ActivityCreateDto dto)
        {
            var activity = await _context.Activities.FindAsync(id);
            if (activity == null || !activity.IsActive) return NotFound(new { message = "Aktivite bulunamadı." });

            activity.Type = (ActivityType)dto.Type;
            activity.Subject = dto.Subject;
            activity.Description = dto.Description;
            activity.ActivityDate = dto.ActivityDate;
            activity.DurationMinutes = dto.DurationMinutes;
            activity.LeadId = dto.LeadId;
            activity.OpportunityId = dto.OpportunityId;
            activity.ContactId = dto.ContactId;
            activity.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Aktivite başarıyla güncellendi." });
        }

        /// <summary>
        /// Aktivite sil (soft delete)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteActivity(Guid id)
        {
            var activity = await _context.Activities.FindAsync(id);
            if (activity == null) return NotFound(new { message = "Aktivite bulunamadı." });

            activity.IsActive = false;
            activity.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Aktivite başarıyla silindi." });
        }

        /// <summary>
        /// Belirli bir entity'nin timeline'ını getir (lead, opportunity veya contact)
        /// </summary>
        [HttpGet("timeline")]
        public async Task<ActionResult> GetTimeline(
            [FromQuery] Guid? leadId,
            [FromQuery] Guid? opportunityId,
            [FromQuery] Guid? contactId)
        {
            var activityQuery = _context.Activities
                .Include(a => a.PerformedBy)
                .Where(a => a.IsActive);

            var taskQuery = _context.CrmTasks
                .Include(t => t.AssignedTo)
                .Where(t => t.IsActive);

            if (leadId.HasValue)
            {
                activityQuery = activityQuery.Where(a => a.LeadId == leadId);
                taskQuery = taskQuery.Where(t => t.LeadId == leadId);
            }
            else if (opportunityId.HasValue)
            {
                activityQuery = activityQuery.Where(a => a.OpportunityId == opportunityId);
                taskQuery = taskQuery.Where(t => t.OpportunityId == opportunityId);
            }
            else if (contactId.HasValue)
            {
                activityQuery = activityQuery.Where(a => a.ContactId == contactId);
                taskQuery = taskQuery.Where(t => t.ContactId == contactId);
            }
            else
            {
                return BadRequest(new { message = "En az bir filtre parametresi gereklidir." });
            }

            var activities = await activityQuery
                .OrderByDescending(a => a.ActivityDate)
                .Select(a => new
                {
                    a.Id,
                    ItemType = "activity",
                    Title = a.Subject,
                    a.Description,
                    Date = a.ActivityDate,
                    Type = (byte)a.Type,
                    UserName = a.PerformedBy.Username,
                    a.DurationMinutes
                })
                .ToListAsync();

            var tasks = await taskQuery
                .OrderByDescending(t => t.CreatedAt)
                .Select(t => new
                {
                    t.Id,
                    ItemType = "task",
                    Title = t.Title,
                    t.Description,
                    Date = t.CreatedAt,
                    Type = (byte)t.Status,
                    UserName = t.AssignedTo.Username,
                    DurationMinutes = (int?)null
                })
                .ToListAsync();

            var timeline = activities.Concat(tasks)
                .OrderByDescending(x => x.Date)
                .ToList();

            return Ok(timeline);
        }

        private Guid GetCurrentUserId()
        {
            return Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        }
    }
}
