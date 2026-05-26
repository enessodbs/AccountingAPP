using AccountingApp.API.Data;
using AccountingApp.API.DTOs;
using AccountingApp.API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AccountingApp.API.Controllers
{
    /// <summary>
    /// Kullanıcı yönetimi endpoint'leri — sadece Admin erişimli.
    /// Kullanıcı oluşturma, listeleme, güncelleme, rol atama ve şifre sıfırlama işlemlerini yönetir.
    /// </summary>
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
        /// Tüm aktif kullanıcıları rolleriyle birlikte listeler.
        /// AsNoTracking ile sadece okuma yapılır, performans optimizasyonu sağlanır.
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<List<UserListDto>>> GetUsers()
        {
            var users = await _context.Users
                .AsNoTracking()
                .Where(u => u.IsActive)
                .OrderBy(u => u.Username)
                .Select(u => new UserListDto
                {
                    Id = u.Id,
                    Username = u.Username,
                    Email = u.Email,
                    FullName = u.FullName,
                    CreatedAt = u.CreatedAt,
                    LastLoginAt = u.LastLoginAt,
                    Roles = u.UserRoles
                        .Where(ur => ur.Role.IsActive)
                        .Select(ur => new RoleSummaryDto
                        {
                            Id = ur.Role.Id,
                            Name = ur.Role.Name
                        })
                        .ToList()
                })
                .ToListAsync();

            return Ok(users);
        }

        /// <summary>
        /// Belirtilen ID'ye sahip kullanıcının detay bilgisini döner.
        /// </summary>
        [HttpGet("{id:guid}")]
        public async Task<ActionResult<UserDetailDto>> GetUser(Guid id)
        {
            var user = await _context.Users
                .AsNoTracking()
                .Where(u => u.Id == id)
                .Select(u => new UserDetailDto
                {
                    Id = u.Id,
                    Username = u.Username,
                    Email = u.Email,
                    FullName = u.FullName,
                    IsActive = u.IsActive,
                    CreatedAt = u.CreatedAt,
                    UpdatedAt = u.UpdatedAt,
                    LastLoginAt = u.LastLoginAt,
                    Roles = u.UserRoles
                        .Where(ur => ur.Role.IsActive)
                        .Select(ur => new RoleSummaryDto
                        {
                            Id = ur.Role.Id,
                            Name = ur.Role.Name
                        })
                        .ToList()
                })
                .FirstOrDefaultAsync();

            if (user == null)
                return NotFound(new { message = "Kullanıcı bulunamadı." });

            return Ok(user);
        }

        /// <summary>
        /// Yeni bir kullanıcı oluşturur ve belirtilen rolleri atar.
        /// Şifre BCrypt ile hashlenir. Rol belirtilmezse varsayılan olarak "Muhasebe" atanır.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateUser([FromBody] CreateUserDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Kullanıcı adı benzersizlik kontrolü
            if (await _context.Users.AnyAsync(u => u.Username == dto.Username.Trim()))
                return BadRequest(new { message = "Bu kullanıcı adı zaten kullanılıyor." });

            // E-posta benzersizlik kontrolü
            if (await _context.Users.AnyAsync(u => u.Email == dto.Email.Trim()))
                return BadRequest(new { message = "Bu e-posta adresi zaten kullanılıyor." });

            var user = new User
            {
                Id = Guid.NewGuid(),
                Username = dto.Username.Trim(),
                Email = dto.Email.Trim(),
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                FullName = dto.FullName?.Trim(),
                CreatedAt = DateTime.UtcNow,
                IsActive = true
            };

            _context.Users.Add(user);

            // Rol atama — belirtilmemişse varsayılan "Muhasebe"
            var roleNames = dto.RoleNames.Count > 0
                ? dto.RoleNames
                : new List<string> { "Muhasebe" };

            var assignedRoles = new List<string>();
            foreach (var roleName in roleNames)
            {
                var role = await _context.Roles
                    .FirstOrDefaultAsync(r => r.Name == roleName.Trim() && r.IsActive);

                if (role == null)
                    return BadRequest(new { message = $"'{roleName}' adında aktif bir rol bulunamadı." });

                _context.UserRoles.Add(new UserRole { UserId = user.Id, RoleId = role.Id });
                assignedRoles.Add(role.Name);
            }

            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetUser), new { id = user.Id },
                new { message = "Kullanıcı başarıyla oluşturuldu.", userId = user.Id, roles = assignedRoles });
        }

        /// <summary>
        /// Kullanıcı bilgilerini günceller (kullanıcı adı, e-posta, tam ad).
        /// Sadece gönderilen alanlar güncellenir (partial update).
        /// </summary>
        [HttpPut("{id:guid}")]
        public async Task<IActionResult> UpdateUser(Guid id, [FromBody] UpdateUserDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = await _context.Users.FindAsync(id);
            if (user == null || !user.IsActive)
                return NotFound(new { message = "Kullanıcı bulunamadı." });

            // Kullanıcı adı benzersizlik kontrolü
            if (!string.IsNullOrWhiteSpace(dto.Username) && dto.Username.Trim() != user.Username)
            {
                var exists = await _context.Users.AnyAsync(u => u.Username == dto.Username.Trim() && u.Id != id);
                if (exists) return BadRequest(new { message = "Bu kullanıcı adı zaten kullanılıyor." });
                user.Username = dto.Username.Trim();
            }

            // E-posta benzersizlik kontrolü
            if (!string.IsNullOrWhiteSpace(dto.Email) && dto.Email.Trim() != user.Email)
            {
                var exists = await _context.Users.AnyAsync(u => u.Email == dto.Email.Trim() && u.Id != id);
                if (exists) return BadRequest(new { message = "Bu e-posta adresi zaten kullanılıyor." });
                user.Email = dto.Email.Trim();
            }

            // Tam ad güncelleme
            if (dto.FullName != null)
            {
                user.FullName = dto.FullName.Trim();
            }

            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Kullanıcı bilgileri güncellendi.", username = user.Username, email = user.Email });
        }

        /// <summary>
        /// Kullanıcının rollerini toptan günceller.
        /// Mevcut roller kaldırılıp yeni roller atanır.
        /// </summary>
        [HttpPut("{id:guid}/roles")]
        public async Task<IActionResult> UpdateUserRoles(Guid id, [FromBody] UpdateUserRolesDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = await _context.Users
                .Include(u => u.UserRoles)
                .FirstOrDefaultAsync(u => u.Id == id && u.IsActive);

            if (user == null)
                return NotFound(new { message = "Kullanıcı bulunamadı." });

            // Mevcut rolleri temizle
            _context.UserRoles.RemoveRange(user.UserRoles);

            // Yeni rolleri ata
            var assignedRoles = new List<string>();
            foreach (var roleName in dto.RoleNames)
            {
                var role = await _context.Roles
                    .FirstOrDefaultAsync(r => r.Name == roleName.Trim() && r.IsActive);

                if (role == null)
                    return BadRequest(new { message = $"'{roleName}' adında aktif bir rol bulunamadı." });

                _context.UserRoles.Add(new UserRole { UserId = user.Id, RoleId = role.Id });
                assignedRoles.Add(role.Name);
            }

            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Kullanıcı rolleri güncellendi.", userId = user.Id, roles = assignedRoles });
        }

        /// <summary>
        /// Kullanıcının şifresini sıfırlar (Admin yetkisiyle).
        /// Yeni şifre BCrypt ile hashlenerek kaydedilir.
        /// </summary>
        [HttpPut("{id:guid}/reset-password")]
        public async Task<IActionResult> ResetPassword(Guid id, [FromBody] ResetPasswordDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = await _context.Users.FindAsync(id);
            if (user == null || !user.IsActive)
                return NotFound(new { message = "Kullanıcı bulunamadı." });

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Şifre başarıyla sıfırlandı." });
        }

        /// <summary>
        /// Kullanıcıyı pasife alır (soft delete).
        /// Veritabanından fiziksel silme yapılmaz, sadece IsActive = false olarak işaretlenir.
        /// </summary>
        [HttpDelete("{id:guid}")]
        public async Task<IActionResult> DeleteUser(Guid id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return NotFound(new { message = "Kullanıcı bulunamadı." });

            if (!user.IsActive)
                return BadRequest(new { message = "Bu kullanıcı zaten pasif durumda." });

            user.IsActive = false;
            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Kullanıcı pasife alındı." });
        }

        /// <summary>
        /// Tüm aktif rolleri listeler.
        /// Geriye dönük uyumluluk için korunmuştur — yeni endpoint: GET /api/roles
        /// </summary>
        [HttpGet("roles")]
        public async Task<ActionResult> GetRoles()
        {
            var roles = await _context.Roles
                .AsNoTracking()
                .Where(r => r.IsActive)
                .OrderBy(r => r.Name)
                .Select(r => new { r.Id, r.Name })
                .ToListAsync();

            return Ok(roles);
        }
    }
}
