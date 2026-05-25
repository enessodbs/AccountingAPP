using AccountingApp.API.Data;
using AccountingApp.API.DTOs;
using AccountingApp.API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AccountingApp.API.Controllers
{
    /// <summary>
    /// Rol yönetimi endpoint'leri — sadece Admin erişimli.
    /// Rollerin listelenmesi, oluşturulması, güncellenmesi ve pasife alınması işlemlerini yönetir.
    /// </summary>
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class RolesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RolesController(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Tüm aktif rolleri kullanıcı sayısıyla birlikte listeler.
        /// N+1 probleminden kaçınmak için tek sorguda projection yapılır.
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<List<RoleListDto>>> GetRoles()
        {
            var roles = await _context.Roles
                .AsNoTracking()
                .Where(r => r.IsActive)
                .OrderBy(r => r.Name)
                .Select(r => new RoleListDto
                {
                    Id = r.Id,
                    Name = r.Name,
                    Description = r.Description,
                    UserCount = r.UserRoles.Count(ur => ur.User.IsActive)
                })
                .ToListAsync();

            return Ok(roles);
        }

        /// <summary>
        /// Belirtilen ID'ye sahip rolün detayını, atanmış kullanıcılarıyla birlikte döner.
        /// </summary>
        [HttpGet("{id:guid}")]
        public async Task<ActionResult<RoleDetailDto>> GetRole(Guid id)
        {
            var role = await _context.Roles
                .AsNoTracking()
                .Where(r => r.Id == id)
                .Select(r => new RoleDetailDto
                {
                    Id = r.Id,
                    Name = r.Name,
                    Description = r.Description,
                    IsActive = r.IsActive,
                    CreatedAt = r.CreatedAt,
                    UpdatedAt = r.UpdatedAt,
                    UserCount = r.UserRoles.Count(ur => ur.User.IsActive),
                    Users = r.UserRoles
                        .Where(ur => ur.User.IsActive)
                        .Select(ur => new RoleUserDto
                        {
                            Id = ur.User.Id,
                            Username = ur.User.Username,
                            Email = ur.User.Email,
                            FullName = ur.User.FullName
                        })
                        .ToList()
                })
                .FirstOrDefaultAsync();

            if (role == null)
                return NotFound(new { message = "Rol bulunamadı." });

            return Ok(role);
        }

        /// <summary>
        /// Yeni bir rol oluşturur. Aynı isimde aktif bir rol varsa hata döner.
        /// NormalizedName otomatik olarak büyük harfe dönüştürülerek set edilir.
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<RoleListDto>> CreateRole([FromBody] CreateRoleDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var normalizedName = dto.Name.Trim().ToUpperInvariant();

            // Aynı isimde aktif rol var mı kontrolü
            var exists = await _context.Roles
                .AnyAsync(r => r.NormalizedName == normalizedName && r.IsActive);

            if (exists)
                return BadRequest(new { message = $"'{dto.Name}' adında bir rol zaten mevcut." });

            var role = new Role
            {
                Id = Guid.NewGuid(),
                Name = dto.Name.Trim(),
                NormalizedName = normalizedName,
                Description = dto.Description?.Trim(),
                CreatedAt = DateTime.UtcNow,
                IsActive = true
            };

            _context.Roles.Add(role);
            await _context.SaveChangesAsync();

            var result = new RoleListDto
            {
                Id = role.Id,
                Name = role.Name,
                Description = role.Description,
                UserCount = 0
            };

            return CreatedAtAction(nameof(GetRole), new { id = role.Id }, result);
        }

        /// <summary>
        /// Mevcut bir rolün bilgilerini günceller (isim ve/veya açıklama).
        /// İsim değiştiğinde NormalizedName de otomatik güncellenir.
        /// </summary>
        [HttpPut("{id:guid}")]
        public async Task<IActionResult> UpdateRole(Guid id, [FromBody] UpdateRoleDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var role = await _context.Roles.FindAsync(id);
            if (role == null || !role.IsActive)
                return NotFound(new { message = "Rol bulunamadı." });

            // İsim değişiyorsa benzersizlik kontrolü yap
            if (!string.IsNullOrWhiteSpace(dto.Name) && dto.Name.Trim() != role.Name)
            {
                var normalizedName = dto.Name.Trim().ToUpperInvariant();
                var exists = await _context.Roles
                    .AnyAsync(r => r.NormalizedName == normalizedName && r.IsActive && r.Id != id);

                if (exists)
                    return BadRequest(new { message = $"'{dto.Name}' adında bir rol zaten mevcut." });

                role.Name = dto.Name.Trim();
                role.NormalizedName = normalizedName;
            }

            // Açıklama güncelleme
            if (dto.Description != null)
            {
                role.Description = dto.Description.Trim();
            }

            role.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Rol başarıyla güncellendi.", roleId = role.Id, roleName = role.Name });
        }

        /// <summary>
        /// Rolü pasife alır (soft delete).
        /// Eğer role atanmış aktif kullanıcılar varsa uyarı mesajı döner ama işlem yine de gerçekleşir.
        /// </summary>
        [HttpDelete("{id:guid}")]
        public async Task<IActionResult> DeleteRole(Guid id)
        {
            var role = await _context.Roles
                .Include(r => r.UserRoles)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (role == null)
                return NotFound(new { message = "Rol bulunamadı." });

            if (!role.IsActive)
                return BadRequest(new { message = "Bu rol zaten pasif durumda." });

            // Admin rolünün silinmesini engelle
            if (role.NormalizedName == "ADMIN")
                return BadRequest(new { message = "Admin rolü silinemez." });

            var activeUserCount = await _context.UserRoles
                .CountAsync(ur => ur.RoleId == id && ur.User.IsActive);

            role.IsActive = false;
            role.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var message = activeUserCount > 0
                ? $"Rol pasife alındı. Dikkat: Bu role atanmış {activeUserCount} aktif kullanıcı bulunmaktadır."
                : "Rol başarıyla pasife alındı.";

            return Ok(new { message, roleId = role.Id, affectedUsers = activeUserCount });
        }
    }
}
