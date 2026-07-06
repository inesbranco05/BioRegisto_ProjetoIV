using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BioRegisto.API.Data;
using BioRegisto.API.Models;

namespace BioRegisto.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ObservationsController : ControllerBase
{
    private readonly BioRegistoDbContext _context;

    public ObservationsController(
        BioRegistoDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<List<Observation>>> GetAll()
    {
        return await _context.Observations.ToListAsync();
    }

    [HttpPost]
    public async Task<ActionResult> Create(
        Observation observation)
    {
        observation.CreatedAt = DateTime.UtcNow;

        _context.Observations.Add(observation);

        await _context.SaveChangesAsync();

        return Ok(observation);
    }
}