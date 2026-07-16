using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using BioRegisto.API.Data;
using BioRegisto.API.DTOs;
using BioRegisto.API.Models;

namespace BioRegisto.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ObservationsController : ControllerBase
{
    private readonly BioRegistoDbContext _context;
    private readonly IWebHostEnvironment _environment;

    public ObservationsController(
        BioRegistoDbContext context,
        IWebHostEnvironment environment)
    {
        _context = context;
        _environment = environment;
    }

    [HttpGet]
    public async Task<ActionResult<List<Observation>>> GetAll()
    {
        var userId = GetCurrentUserId();

        if (userId == null)
        {
            return Unauthorized();
        }

        var observations =
            await _context.Observations
                .Where(
                    observation =>
                        observation.UserId == userId
                )
                .OrderByDescending(
                    observation =>
                        observation.CreatedAt
                )
                .ToListAsync();

        return Ok(observations);
    }

    // Devolve todas as observações da comunidade
    [HttpGet("map")]
    public async Task<ActionResult<List<Observation>>> GetMapObservations()
    {
        var observations =
            await _context.Observations
                .OrderByDescending(
                    observation =>
                        observation.CreatedAt
                )
                .ToListAsync();

        return Ok(observations);
    }

    [HttpPost]
    public async Task<ActionResult> Create(
        [FromForm] CreateObservationDto request)
    {
        var userId = GetCurrentUserId();

        if (userId == null)
        {
            return Unauthorized();
        }

        string? imageUrl = null;

        // Guardar fotografia
        if (request.Image != null &&
            request.Image.Length > 0)
        {
            var uploadsFolder = Path.Combine(
                _environment.WebRootPath,
                "uploads",
                "observations"
            );

            Directory.CreateDirectory(
                uploadsFolder
            );

            var extension =
                Path.GetExtension(
                    request.Image.FileName
                );

            var fileName =
                $"{Guid.NewGuid()}{extension}";

            var filePath =
                Path.Combine(
                    uploadsFolder,
                    fileName
                );

            await using var stream =
                new FileStream(
                    filePath,
                    FileMode.Create
                );

            await request.Image.CopyToAsync(
                stream
            );

            imageUrl =
                $"/uploads/observations/{fileName}";
        }

        var observation =
            new Observation
            {
                ScientificName =
                    request.ScientificName,

                CommonName =
                    request.CommonName,

               Latitude = double.Parse(
                    request.Latitude,
                    System.Globalization.CultureInfo.InvariantCulture
                ),

                Longitude = double.Parse(
                    request.Longitude,
                    System.Globalization.CultureInfo.InvariantCulture
                ),

                Status = "Pending",

                CreatedAt =
                    DateTime.UtcNow,

                UserId =
                    userId.Value,

                ImageUrl =
                    imageUrl
            };

        _context.Observations.Add(
            observation
        );

        await _context.SaveChangesAsync();

        return Ok(observation);
    }

    private int? GetCurrentUserId()
    {
        var userIdClaim =
            User.FindFirst(
                ClaimTypes.NameIdentifier
            );

        if (userIdClaim == null)
        {
            return null;
        }

        if (!int.TryParse(
            userIdClaim.Value,
            out var userId))
        {
            return null;
        }

        return userId;
    }

// GET api/Observations/admin
[HttpGet("admin")]
[Authorize(Roles = "Admin")]
public async Task<IActionResult> GetAdminObservations()
{
    var observations =
        await _context.Observations
            .Include(o => o.User)
            .OrderByDescending(
                o => o.CreatedAt
            )
            .Select(o => new
            {
                o.Id,

                o.ScientificName,
                o.CommonName,

                o.Status,

                o.Latitude,
                o.Longitude,

                o.CreatedAt,

                UserName =
                    o.User != null
                        ? o.User.Name
                        : "Utilizador desconhecido",

                UserEmail =
                    o.User != null
                        ? o.User.Email
                        : null
            })
            .ToListAsync();

    return Ok(observations);
}

}