using AccountingApp.API.Data;
using AccountingApp.API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AccountingApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class UserManagementController : ControllerBase
    {
        private readonly AppDbContext _context;

        public UserManagementController(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Tüm kullanıcıları rolleriyle birlikte listeler (Admin only)
        /// </summary>
        [HttpGet]
        public async Task<ActionResult> GetUsers()
        {
            var users = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .Where(u => u.IsActive)
                .OrderBy(u => u.Username)
                .Select(u => new
                {
                    u.Id,
                    u.Username,
                    u.Email,
                    u.CreatedAt,
                    Roles = u.UserRoles.Select(ur => new { ur.Role.Id, ur.Role.Name }).ToList()
                })
                .ToListAsync();

            return Ok(users);
        }

        /// <summary>
        /// Kullanıcı rollerini günceller (Admin only)
        /// </summary>
        [HttpPut("{id}/roles")]
        public async Task<IActionResult> UpdateUserRoles(Guid id, [FromBody] UpdateRolesRequest request)
        {
            var user = await _context.Users
                .Include(u => u.UserRoles)
                .FirstOrDefaultAsync(u => u.Id == id && u.IsActive);

            if (user == null) return NotFound(new { message = "Kullanıcı bulunamadı." });

            // Remove existing roles
            _context.UserRoles.RemoveRange(user.UserRoles);

            // Add new roles
            foreach (var roleName in request.RoleNames)
            {
                var role = await _context.Roles.FirstOrDefaultAsync(r => r.Name == roleName && r.IsActive);
                if (role != null)
                {
                    _context.UserRoles.Add(new UserRole { UserId = user.Id, RoleId = role.Id });
                }
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Kullanıcı rolleri güncellendi.", userId = user.Id, roles = request.RoleNames });
        }

        /// <summary>
        /// Kullanıcıyı pasife alır (soft delete) (Admin only)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(Guid id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null) return NotFound(new { message = "Kullanıcı bulunamadı." });

            user.IsActive = false;
            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Kullanıcı pasife alındı." });
        }

        /// <summary>
        /// Tüm mevcut rolleri listeler
        /// </summary>
        [HttpGet("roles")]
        public async Task<ActionResult> GetRoles()
        {
            var roles = await _context.Roles
                .Where(r => r.IsActive)
                .Select(r => new { r.Id, r.Name })
                .ToListAsync();

            return Ok(roles);
        }
    }

    public class UpdateRolesRequest
    {
        public List<string> RoleNames { get; set; } = new List<string>();
    }
}
