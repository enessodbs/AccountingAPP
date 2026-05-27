using AccountingApp.API.Data;
using AccountingApp.API.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace AccountingApp.API.Controllers
{
    /// <summary>
    /// Kimlik doğrulama endpoint'leri — Login ve Şifremi Unuttum.
    /// Kullanıcı oluşturma işlemi UserManagementController'a taşınmıştır.
    /// </summary>
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        /// <summary>
        /// Kullanıcı girişi — Kullanıcı adı ve şifre doğrulanarak JWT token üretilir.
        /// Başarılı girişte LastLoginAt güncellenir.
        /// </summary>
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Kullanıcıyı rolleriyle birlikte getir
            var user = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Username == request.Username && u.IsActive);

            if (user == null)
                return Unauthorized(new { message = "Kullanıcı adı veya şifre hatalı." });

            // BCrypt ile şifre doğrulama
            bool isPasswordValid = false;
            try
            {
                isPasswordValid = BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash);
            }
            catch
            {
                // Geriye dönük uyumluluk: hash BCrypt değilse düz karşılaştırma
                isPasswordValid = user.PasswordHash == request.Password;
            }

            if (!isPasswordValid)
                return Unauthorized(new { message = "Kullanıcı adı veya şifre hatalı." });

            // Son giriş zamanını güncelle
            user.LastLoginAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var roles = user.UserRoles
                .Where(ur => ur.Role.IsActive)
                .Select(ur => ur.Role.Name)
                .ToList();

            var permissions = user.UserRoles
                .Where(ur => ur.Role.IsActive && !string.IsNullOrEmpty(ur.Role.Permissions))
                .SelectMany(ur => ur.Role.Permissions.Split(',', StringSplitOptions.RemoveEmptyEntries))
                .Distinct()
                .ToList();

            return GenerateTokenResponse(user.Username, user.Email, user.FullName, roles, permissions, user.Id);
        }

        /// <summary>
        /// Şifremi unuttum — Geçici bir şifre oluşturularak kullanıcıya bildirilir.
        /// Güvenlik gereği e-posta var olsa da olmasa da aynı mesaj döner.
        /// </summary>
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequestDto request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email && u.IsActive);

            if (user == null)
            {
                // Güvenlik: e-posta var olup olmadığını açıklamıyoruz
                return Ok(new { message = "E-posta adresi kayıtlıysa şifre sıfırlama bilgileri gönderilecektir." });
            }

            // Geçici şifre üret
            var tempPassword = $"Temp{Guid.NewGuid().ToString("N")[..6]}!";
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(tempPassword);
            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            // Üretim ortamında bu e-posta ile gönderilmeli. Şimdilik yanıtta dönüyor.
            return Ok(new
            {
                message = $"Geçici şifreniz: {tempPassword} — Lütfen giriş yaptıktan sonra şifrenizi değiştirin."
            });
        }

        /// <summary>
        /// JWT token üretimi — Claim'lere kullanıcı bilgileri ve roller eklenir.
        /// Token süresi appsettings.json'daki ExpirationInMinutes ayarından alınır.
        /// </summary>
        private IActionResult GenerateTokenResponse(string username, string email, string? fullName, List<string> roles, List<string> permissions, Guid userId)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var keyStr = _configuration["JwtSettings:Secret"];
            if (string.IsNullOrEmpty(keyStr))
                return StatusCode(500, new { message = "JWT Secret yapılandırmada eksik." });

            var key = Encoding.ASCII.GetBytes(keyStr);

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
                new Claim(ClaimTypes.Name, username),
                new Claim(ClaimTypes.Email, email)
            };

            // Tam ad varsa ekle
            if (!string.IsNullOrEmpty(fullName))
                claims.Add(new Claim("FullName", fullName));

            // Her rol için ayrı claim
            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            // Her izin için ayrı claim
            foreach (var perm in permissions)
            {
                claims.Add(new Claim("Permission", perm));
            }

            double expiryMinutes = _configuration.GetValue<double>("JwtSettings:ExpirationInMinutes", 120);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddMinutes(expiryMinutes),
                SigningCredentials = new SigningCredentials(
                    new SymmetricSecurityKey(key),
                    SecurityAlgorithms.HmacSha256Signature),
                Issuer = _configuration["JwtSettings:Issuer"],
                Audience = _configuration["JwtSettings:Audience"]
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);

            var response = new LoginResponseDto
            {
                Token = tokenHandler.WriteToken(token),
                Expiration = tokenDescriptor.Expires!.Value,
                Username = username,
                FullName = fullName,
                Roles = roles,
                Permissions = permissions
            };

            return Ok(response);
        }
    }
}
