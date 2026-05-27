using AccountingApp.API.Data;
using AccountingApp.API.DTOs;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AccountingApp.API.Models;

namespace AccountingApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class CurrenciesController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public CurrenciesController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<CurrencyDto>>> GetCurrencies()
        {
            var currencies = await _context.Currencies
                .Where(c => c.IsActive)
                .OrderBy(c => c.Id)
                .ToListAsync();

            return Ok(_mapper.Map<IEnumerable<CurrencyDto>>(currencies));
        }

        [HttpGet("live-rates")]
        public async Task<ActionResult> GetLiveRates()
        {
            try
            {
                using var client = new HttpClient();
                // Fetch live rates relative to TRY (Turkish Lira)
                var response = await client.GetAsync("https://open.er-api.com/v6/latest/TRY");
                if (!response.IsSuccessStatusCode)
                {
                    return StatusCode(500, "Döviz kurları alınamadı.");
                }

                var content = await response.Content.ReadAsStringAsync();
                var result = System.Text.Json.JsonSerializer.Deserialize<System.Text.Json.JsonElement>(content);
                var rates = result.GetProperty("rates");

                var availableCurrencies = await _context.Currencies.Where(c => c.IsActive).ToListAsync();

                var exchangeRates = new List<object>();

                foreach (var currency in availableCurrencies)
                {
                    if (currency.Code == "TRY")
                    {
                        exchangeRates.Add(new { code = currency.Code, symbol = currency.Symbol, rate = 1.0m });
                    }
                    else
                    {
                        if (rates.TryGetProperty(currency.Code, out var rateElement))
                        {
                            var rateValue = rateElement.GetDecimal();
                            // If base is TRY, then 1 TRY = Rate USD. So 1 USD = 1 / Rate TRY.
                            var tryEquivalent = rateValue > 0 ? 1 / rateValue : 0;
                            exchangeRates.Add(new { code = currency.Code, symbol = currency.Symbol, rate = Math.Round(tryEquivalent, 4) });
                        }
                    }
                }

                return Ok(exchangeRates);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Hata: {ex.Message}");
            }
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<CurrencyDto>> PostCurrency([FromBody] CurrencyCreateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var normalizedCode = dto.Code.Trim().ToUpperInvariant();

            var exists = await _context.Currencies
                .AnyAsync(c => c.Code == normalizedCode && c.IsActive);

            if (exists)
                return BadRequest(new { message = $"'{normalizedCode}' kodlu bir döviz zaten mevcut." });

            var currency = new Currency
            {
                Code = normalizedCode,
                Symbol = dto.Symbol?.Trim(),
                CreatedAt = DateTime.UtcNow,
                IsActive = true
            };

            _context.Currencies.Add(currency);
            await _context.SaveChangesAsync();

            return Ok(_mapper.Map<CurrencyDto>(currency));
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteCurrency(int id)
        {
            var currency = await _context.Currencies.FindAsync(id);
            if (currency == null) return NotFound();

            if (currency.Code == "TRY" || currency.Code == "USD" || currency.Code == "EUR")
                return BadRequest(new { message = "Sistem varsayılan kurları silinemez." });

            currency.IsActive = false;
            currency.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
