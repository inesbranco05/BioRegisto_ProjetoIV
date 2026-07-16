using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BioRegisto.API.Data;

namespace BioRegisto.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class AdminController : ControllerBase
{
    private readonly BioRegistoDbContext _context;

    public AdminController(
        BioRegistoDbContext context)
    {
        _context = context;
    }

    // GET api/Admin/statistics
    [HttpGet("statistics")]
    public async Task<IActionResult> GetStatistics()
    {
        var totalUsers =
            await _context.Users.CountAsync();

        var activeUsers =
            await _context.Users.CountAsync(
                u => u.IsActive
            );

        var observers =
            await _context.Users.CountAsync(
                u => u.Role == "Observer"
            );

        var validators =
            await _context.Users.CountAsync(
                u => u.Role == "Validator"
            );

        var totalObservations =
            await _context.Observations.CountAsync();

        var pendingObservations =
            await _context.Observations.CountAsync(
                o => o.Status == "Pending"
            );

        var validatedObservations =
            await _context.Observations.CountAsync(
                o => o.Status == "Validated"
            );

        var rejectedObservations =
            await _context.Observations.CountAsync(
                o => o.Status == "Rejected"
            );

        var totalSpecies =
            await _context.Taxa.CountAsync(
                t => t.Rank == "Species"
            );

        var totalNotifications =
            await _context.Notifications.CountAsync();

        return Ok(new
        {
            users = new
            {
                total = totalUsers,
                active = activeUsers,
                observers,
                validators
            },

            observations = new
            {
                total = totalObservations,
                pending = pendingObservations,
                validated = validatedObservations,
                rejected = rejectedObservations
            },

            species = totalSpecies,

            notifications = totalNotifications
        });
    }
}