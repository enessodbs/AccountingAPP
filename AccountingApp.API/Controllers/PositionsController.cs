using AccountingApp.API.Data;
using AccountingApp.API.DTOs;
using AccountingApp.API.Models;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AccountingApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PositionsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public PositionsController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<PositionDto>>> GetPositions([FromQuery] int? departmentId)
        {
            var query = _context.Positions
                .Include(p => p.Department)
                .Where(p => p.IsActive);

            if (departmentId.HasValue)
            {
                query = query.Where(p => p.DepartmentId == departmentId.Value);
            }

            var positions = await query.OrderBy(p => p.Name).ToListAsync();
            return Ok(_mapper.Map<IEnumerable<PositionDto>>(positions));
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PositionDto>> GetPosition(int id)
        {
            var position = await _context.Positions
                .Include(p => p.Department)
                .FirstOrDefaultAsync(p => p.Id == id && p.IsActive);

            if (position == null) return NotFound();

            return Ok(_mapper.Map<PositionDto>(position));
        }

        [HttpPost]
        [Authorize(Roles = "Admin,İK")]
        public async Task<ActionResult<PositionDto>> CreatePosition([FromBody] PositionCreateDto dto)
        {
            var dept = await _context.Departments.FindAsync(dto.DepartmentId);
            if (dept == null || !dept.IsActive)
                return BadRequest("Geçersiz departman.");

            var position = new Position
            {
                Name = dto.Name,
                DepartmentId = dto.DepartmentId,
                IsActive = true
            };

            _context.Positions.Add(position);
            await _context.SaveChangesAsync();

            position.Department = dept;

            return CreatedAtAction(nameof(GetPosition), new { id = position.Id }, _mapper.Map<PositionDto>(position));
        }
    }
}
