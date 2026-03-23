using AccountingApp.API.Data;
using AccountingApp.API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace AccountingApp.API.Controllers
{
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

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            // Find user by username
            var user = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Username == request.Username && u.IsActive);

            if (user == null)
            {
                return Unauthorized(new { message = "Kullanıcı adı veya şifre hatalı." });
            }

            // Verify password with BCrypt
            bool isPasswordValid = false;
            try
            {
                isPasswordValid = BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash);
            }
            catch
            {
                // Backward compatibility: if hash is not BCrypt, do direct comparison
                isPasswordValid = user.PasswordHash == request.Password;
            }

            if (!isPasswordValid)
            {
                return Unauthorized(new { message = "Kullanıcı adı veya şifre hatalı." });
            }

            var roles = user.UserRoles.Select(ur => ur.Role.Name).ToList();
            return GenerateTokenResponse(user.Username, user.Email, roles, user.Id);
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email && u.IsActive);

            if (user == null)
            {
                // Don't reveal whether the email exists for security
                return Ok(new { message = "E-posta adresi kayıtlıysa şifre sıfırlama bilgileri gönderilecektir." });
            }

            // Generate a temporary password
            var tempPassword = $"Temp{Guid.NewGuid().ToString("N").Substring(0, 6)}!";
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(tempPassword);
            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            // In production, send this via email. For now, return it in the response.
            return Ok(new { 
                message = $"Geçici şifreniz: {tempPassword} — Lütfen giriş yaptıktan sonra şifrenizi değiştirin." 
            });
        }

        [HttpPost("register")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            // Check if username or email already exists
            if (await _context.Users.AnyAsync(u => u.Username == request.Username))
            {
                return BadRequest(new { message = "Bu kullanıcı adı zaten kullanılıyor." });
            }

            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
            {
                return BadRequest(new { message = "Bu e-posta adresi zaten kullanılıyor." });
            }

            // Hash password with BCrypt
            var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

            var user = new User
            {
                Id = Guid.NewGuid(),
                Username = request.Username,
                Email = request.Email,
                PasswordHash = passwordHash,
                CreatedAt = DateTime.UtcNow,
                IsActive = true
            };

            _context.Users.Add(user);

            // Assign the specified role, default to "Muhasebe" if not provided
            var roleName = string.IsNullOrEmpty(request.RoleName) ? "Muhasebe" : request.RoleName;
            var role = await _context.Roles.FirstOrDefaultAsync(r => r.Name == roleName && r.IsActive);
            if (role != null)
            {
                _context.UserRoles.Add(new UserRole { UserId = user.Id, RoleId = role.Id });
            }
            else
            {
                return BadRequest(new { message = $"'{roleName}' adında bir rol bulunamadı." });
            }

            await _context.SaveChangesAsync();

            return Ok(new { message = "Kullanıcı başarıyla oluşturuldu.", userId = user.Id, role = roleName });
        }

        private IActionResult GenerateTokenResponse(string username, string email, List<string> roles, Guid userId)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var keyStr = _configuration["JwtSettings:Secret"];
            if (string.IsNullOrEmpty(keyStr)) {
                return StatusCode(500, "JWT Secret Is missing in config");
            }

            var key = Encoding.ASCII.GetBytes(keyStr);

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
                new Claim(ClaimTypes.Name, username),
                new Claim(ClaimTypes.Email, email)
            };

            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            double expiryMinutes = _configuration.GetValue<double>("JwtSettings:ExpirationInMinutes", 120);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddMinutes(expiryMinutes),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature),
                Issuer = _configuration["JwtSettings:Issuer"],
                Audience = _configuration["JwtSettings:Audience"]
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);

            var response = new LoginResponse
            {
                Token = tokenHandler.WriteToken(token),
                Expiration = tokenDescriptor.Expires.Value,
                Username = username,
                Roles = roles
            };

            return Ok(response);
        }

    }

    public class RegisterRequest
    {
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string? RoleName { get; set; }
    }

    public class ForgotPasswordRequest
    {
        public string Email { get; set; } = string.Empty;
    }
}
