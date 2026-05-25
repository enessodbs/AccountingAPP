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
    public class CrmTasksController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public CrmTasksController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        /// <summary>
        /// Tüm görevleri listele (filtreli)
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<CrmTaskDto>>> GetTasks(
            [FromQuery] byte? status,
            [FromQuery] byte? priority,
            [FromQuery] Guid? assignedToId,
            [FromQuery] Guid? leadId,
            [FromQuery] Guid? opportunityId,
            [FromQuery] Guid? contactId)
        {
            var userId = GetCurrentUserId();
            var userRoles = GetCurrentUserRoles();

            var query = _context.CrmTasks
                .Include(t => t.AssignedTo)
                .Include(t => t.CreatedBy)
                .Include(t => t.Lead)
                .Include(t => t.Opportunity)
                .Include(t => t.Contact)
                .Where(t => t.IsActive);

            // Row-level: Satış rolü sadece kendi görevlerini görsün
            if (userRoles.Contains("Satış") && !userRoles.Contains("Admin") && !userRoles.Contains("SatışYönetici"))
            {
                query = query.Where(t => t.AssignedToId == userId || t.CreatedById == userId);
            }

            if (status.HasValue)
                query = query.Where(t => (byte)t.Status == status.Value);

            if (priority.HasValue)
                query = query.Where(t => (byte)t.Priority == priority.Value);

            if (assignedToId.HasValue)
                query = query.Where(t => t.AssignedToId == assignedToId.Value);

            if (leadId.HasValue)
                query = query.Where(t => t.LeadId == leadId.Value);

            if (opportunityId.HasValue)
                query = query.Where(t => t.OpportunityId == opportunityId.Value);

            if (contactId.HasValue)
                query = query.Where(t => t.ContactId == contactId.Value);

            var tasks = await query
                .OrderByDescending(t => t.CreatedAt)
                .Select(t => new CrmTaskDto
                {
                    Id = t.Id,
                    Title = t.Title,
                    Description = t.Description,
                    Priority = (byte)t.Priority,
                    Status = (byte)t.Status,
                    DueDate = t.DueDate,
                    CompletedAt = t.CompletedAt,
                    AssignedToId = t.AssignedToId,
                    AssignedToName = t.AssignedTo.Username,
                    CreatedById = t.CreatedById,
                    CreatedByName = t.CreatedBy.Username,
                    LeadId = t.LeadId,
                    LeadName = t.Lead != null ? t.Lead.FirstName + " " + t.Lead.LastName : null,
                    OpportunityId = t.OpportunityId,
                    OpportunityTitle = t.Opportunity != null ? t.Opportunity.Title : null,
                    ContactId = t.ContactId,
                    ContactName = t.Contact != null ? t.Contact.Name : null,
                    CreatedAt = t.CreatedAt,
                    IsActive = t.IsActive
                })
                .ToListAsync();

            return Ok(tasks);
        }

        /// <summary>
        /// Bana atanmış görevler
        /// </summary>
        [HttpGet("my")]
        public async Task<ActionResult<IEnumerable<CrmTaskDto>>> GetMyTasks([FromQuery] byte? status)
        {
            var userId = GetCurrentUserId();

            var query = _context.CrmTasks
                .Include(t => t.AssignedTo)
                .Include(t => t.CreatedBy)
                .Include(t => t.Lead)
                .Include(t => t.Opportunity)
                .Include(t => t.Contact)
                .Where(t => t.IsActive && t.AssignedToId == userId);

            if (status.HasValue)
                query = query.Where(t => (byte)t.Status == status.Value);

            var tasks = await query
                .OrderBy(t => t.DueDate)
                .ThenByDescending(t => t.Priority)
                .Select(t => new CrmTaskDto
                {
                    Id = t.Id,
                    Title = t.Title,
                    Description = t.Description,
                    Priority = (byte)t.Priority,
                    Status = (byte)t.Status,
                    DueDate = t.DueDate,
                    CompletedAt = t.CompletedAt,
                    AssignedToId = t.AssignedToId,
                    AssignedToName = t.AssignedTo.Username,
                    CreatedById = t.CreatedById,
                    CreatedByName = t.CreatedBy.Username,
                    LeadId = t.LeadId,
                    LeadName = t.Lead != null ? t.Lead.FirstName + " " + t.Lead.LastName : null,
                    OpportunityId = t.OpportunityId,
                    OpportunityTitle = t.Opportunity != null ? t.Opportunity.Title : null,
                    ContactId = t.ContactId,
                    ContactName = t.Contact != null ? t.Contact.Name : null,
                    CreatedAt = t.CreatedAt,
                    IsActive = t.IsActive
                })
                .ToListAsync();

            return Ok(tasks);
        }

        /// <summary>
        /// Görev detayı
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<CrmTaskDto>> GetTask(Guid id)
        {
            var task = await _context.CrmTasks
                .Include(t => t.AssignedTo)
                .Include(t => t.CreatedBy)
                .Include(t => t.Lead)
                .Include(t => t.Opportunity)
                .Include(t => t.Contact)
                .FirstOrDefaultAsync(t => t.Id == id && t.IsActive);

            if (task == null) return NotFound(new { message = "Görev bulunamadı." });

            var dto = new CrmTaskDto
            {
                Id = task.Id,
                Title = task.Title,
                Description = task.Description,
                Priority = (byte)task.Priority,
                Status = (byte)task.Status,
                DueDate = task.DueDate,
                CompletedAt = task.CompletedAt,
                AssignedToId = task.AssignedToId,
                AssignedToName = task.AssignedTo.Username,
                CreatedById = task.CreatedById,
                CreatedByName = task.CreatedBy.Username,
                LeadId = task.LeadId,
                LeadName = task.Lead != null ? $"{task.Lead.FirstName} {task.Lead.LastName}" : null,
                OpportunityId = task.OpportunityId,
                OpportunityTitle = task.Opportunity?.Title,
                ContactId = task.ContactId,
                ContactName = task.Contact?.Name,
                CreatedAt = task.CreatedAt,
                IsActive = task.IsActive
            };

            return Ok(dto);
        }

        /// <summary>
        /// Yeni görev oluştur
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<CrmTaskDto>> CreateTask(CrmTaskCreateDto dto)
        {
            var userId = GetCurrentUserId();

            // Atanan kullanıcıyı doğrula
            var assignedUser = await _context.Users.FindAsync(dto.AssignedToId);
            if (assignedUser == null || !assignedUser.IsActive)
                return BadRequest(new { message = "Atanan kullanıcı bulunamadı." });

            var task = new CrmTask
            {
                Id = Guid.NewGuid(),
                Title = dto.Title,
                Description = dto.Description,
                Priority = (CrmTaskPriority)dto.Priority,
                Status = CrmTaskStatus.Todo,
                DueDate = dto.DueDate,
                AssignedToId = dto.AssignedToId,
                CreatedById = userId,
                LeadId = dto.LeadId,
                OpportunityId = dto.OpportunityId,
                ContactId = dto.ContactId,
                CreatedAt = DateTime.UtcNow
            };

            _context.CrmTasks.Add(task);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetTask), new { id = task.Id },
                new { id = task.Id, message = "Görev başarıyla oluşturuldu." });
        }

        /// <summary>
        /// Görev güncelle
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTask(Guid id, CrmTaskUpdateDto dto)
        {
            var task = await _context.CrmTasks.FindAsync(id);
            if (task == null || !task.IsActive) return NotFound(new { message = "Görev bulunamadı." });

            task.Title = dto.Title;
            task.Description = dto.Description;
            task.Priority = (CrmTaskPriority)dto.Priority;
            task.DueDate = dto.DueDate;
            task.AssignedToId = dto.AssignedToId;
            task.LeadId = dto.LeadId;
            task.OpportunityId = dto.OpportunityId;
            task.ContactId = dto.ContactId;
            task.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Görev başarıyla güncellendi." });
        }

        /// <summary>
        /// Görev durumunu değiştir
        /// </summary>
        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateTaskStatus(Guid id, CrmTaskStatusUpdateDto dto)
        {
            var task = await _context.CrmTasks.FindAsync(id);
            if (task == null || !task.IsActive) return NotFound(new { message = "Görev bulunamadı." });

            task.Status = (CrmTaskStatus)dto.Status;

            if (task.Status == CrmTaskStatus.Done)
            {
                task.CompletedAt = DateTime.UtcNow;
            }
            else
            {
                task.CompletedAt = null;
            }

            task.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Görev durumu güncellendi.", status = dto.Status });
        }

        /// <summary>
        /// Görev sil (soft delete)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTask(Guid id)
        {
            var task = await _context.CrmTasks.FindAsync(id);
            if (task == null) return NotFound(new { message = "Görev bulunamadı." });

            task.IsActive = false;
            task.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Görev başarıyla silindi." });
        }

        /// <summary>
        /// Görev istatistikleri
        /// </summary>
        [HttpGet("stats")]
        public async Task<ActionResult> GetTaskStats()
        {
            var userId = GetCurrentUserId();

            var myTasks = _context.CrmTasks.Where(t => t.IsActive && t.AssignedToId == userId);

            var total = await myTasks.CountAsync();
            var todo = await myTasks.CountAsync(t => t.Status == CrmTaskStatus.Todo);
            var inProgress = await myTasks.CountAsync(t => t.Status == CrmTaskStatus.InProgress);
            var done = await myTasks.CountAsync(t => t.Status == CrmTaskStatus.Done);
            var overdue = await myTasks.CountAsync(t =>
                t.DueDate.HasValue && t.DueDate.Value < DateTime.UtcNow &&
                t.Status != CrmTaskStatus.Done && t.Status != CrmTaskStatus.Cancelled);

            return Ok(new
            {
                total,
                todo,
                inProgress,
                done,
                overdue
            });
        }

        private Guid GetCurrentUserId()
        {
            return Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        }

        private List<string> GetCurrentUserRoles()
        {
            return User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();
        }
    }
}
