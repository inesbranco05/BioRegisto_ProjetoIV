using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BioRegisto.API.Data;
using BioRegisto.API.DTOs;
using BioRegisto.API.Models;

namespace BioRegisto.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class EventChallengesController : ControllerBase
{
    private readonly BioRegistoDbContext _context;

    public EventChallengesController(
        BioRegistoDbContext context)
    {
        _context = context;
    }

    // GET api/EventChallenges
    // Todos os utilizadores autenticados podem consultar.
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var items = await _context
            .EventChallenges
            .OrderByDescending(e => e.StartDate)
            .Select(e => new
            {
                e.Id,
                e.Title,
                e.Description,
                e.Type,
                e.StartDate,
                e.EndDate,
                e.IsActive,
                e.CreatedAt
            })
            .ToListAsync();

        return Ok(items);
    }

    // POST api/EventChallenges
    // Apenas Admin pode criar.
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create(
        CreateEventChallengeDto request)
    {
        if (string.IsNullOrWhiteSpace(request.Title) ||
            string.IsNullOrWhiteSpace(request.Description))
        {
            return BadRequest(new
            {
                message =
                    "O título e a descrição são obrigatórios."
            });
        }

        var validTypes = new[]
        {
            "Event",
            "Challenge"
        };

        if (!validTypes.Contains(request.Type))
        {
            return BadRequest(new
            {
                message =
                    "O tipo deve ser Event ou Challenge."
            });
        }

        if (request.EndDate < request.StartDate)
        {
            return BadRequest(new
            {
                message =
                    "A data de fim não pode ser anterior à data de início."
            });
        }

        var item = new EventChallenge
        {
            Title = request.Title.Trim(),
            Description =
                request.Description.Trim(),
            Type = request.Type,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _context.EventChallenges.Add(item);

        await _context.SaveChangesAsync();

        return Ok(item);
    }

    // PUT api/EventChallenges/5
    // Apenas Admin pode editar.
    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(
        int id,
        UpdateEventChallengeDto request)
    {
        var item =
            await _context.EventChallenges
                .FindAsync(id);

        if (item == null)
        {
            return NotFound(new
            {
                message =
                    "Evento ou desafio não encontrado."
            });
        }

        if (string.IsNullOrWhiteSpace(request.Title) ||
            string.IsNullOrWhiteSpace(request.Description))
        {
            return BadRequest(new
            {
                message =
                    "O título e a descrição são obrigatórios."
            });
        }

        var validTypes = new[]
        {
            "Event",
            "Challenge"
        };

        if (!validTypes.Contains(request.Type))
        {
            return BadRequest(new
            {
                message =
                    "O tipo deve ser Event ou Challenge."
            });
        }

        if (request.EndDate < request.StartDate)
        {
            return BadRequest(new
            {
                message =
                    "A data de fim não pode ser anterior à data de início."
            });
        }

        item.Title =
            request.Title.Trim();

        item.Description =
            request.Description.Trim();

        item.Type =
            request.Type;

        item.StartDate =
            request.StartDate;

        item.EndDate =
            request.EndDate;

        item.IsActive =
            request.IsActive;

        await _context.SaveChangesAsync();

        return Ok(item);
    }

    // PATCH api/EventChallenges/5/toggle-status
    // Ativa ou desativa sem eliminar.
    [HttpPatch("{id:int}/toggle-status")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> ToggleStatus(
        int id)
    {
        var item =
            await _context.EventChallenges
                .FindAsync(id);

        if (item == null)
        {
            return NotFound(new
            {
                message =
                    "Evento ou desafio não encontrado."
            });
        }

        item.IsActive =
            !item.IsActive;

        await _context.SaveChangesAsync();

        return Ok(new
        {
            item.Id,
            item.IsActive
        });
    }
}