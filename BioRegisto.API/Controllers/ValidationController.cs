using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BioRegisto.API.Data;
using BioRegisto.API.DTOs;
using System.Security.Claims;

namespace BioRegisto.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Validator,Admin")]
public class ValidationController : ControllerBase
{
    private readonly BioRegistoDbContext _context;

    public ValidationController(
        BioRegistoDbContext context)
    {
        _context = context;
    }

    // GET api/Validation/pending
    [HttpGet("pending")]
    public async Task<IActionResult> GetPending()
    {
        var observations =
            await _context.Observations
                .Where(o => o.Status == "Pending")
                .OrderBy(o => o.CreatedAt)
                .ToListAsync();

        return Ok(observations);
    }

    // PUT api/Validation/{id}/approve
  [HttpPut("{id}/approve")]
    public async Task<IActionResult> Approve(
        int id,
        ValidateObservationDto request)
    {
        var observation =
            await _context.Observations
                .FindAsync(id);

        if (observation == null)
        {
            return NotFound(new
            {
                message = "Observação não encontrada."
            });
        }

        if (observation.Status != "Pending")
        {
            return BadRequest(new
            {
                message =
                    "Esta observação já foi processada."
            });
        }

        var taxon =
            await _context.Taxa
                .FindAsync(request.TaxonId);

        if (taxon == null)
        {
            return BadRequest(new
            {
                message =
                    "O táxon selecionado não existe."
            });
        }

        if (taxon.Rank != "Species")
        {
            return BadRequest(new
            {
                message =
                    "A classificação final deve corresponder a uma espécie."
            });
        }

        var userIdClaim =
            User.FindFirstValue(
                ClaimTypes.NameIdentifier
            );

        if (!int.TryParse(
            userIdClaim,
            out var validatorId))
        {
            return Unauthorized();
        }

        observation.TaxonId =
            request.TaxonId;

        // Permite corrigir a identificação
        observation.CommonName =
            request.CommonName.Trim();

        observation.ScientificName =
            request.ScientificName.Trim();

        observation.ValidationNotes =
            request.Notes?.Trim();

        observation.Status =
            "Validated";

        observation.ValidatedByUserId =
            validatorId;

        observation.ValidatedAt =
            DateTime.UtcNow;

        // Limpa eventual informação anterior
        observation.RejectionReason =
            null;

        await _context.SaveChangesAsync();

        return Ok(new
        {
            message =
                "Observação validada com sucesso."
        });
    }

    // PUT api/Validation/{id}/reject
  [HttpPut("{id}/reject")]
    public async Task<IActionResult> Reject(
        int id,
        RejectObservationDto request)
    {
        if (string.IsNullOrWhiteSpace(
            request.Reason))
        {
            return BadRequest(new
            {
                message =
                    "É obrigatório indicar uma justificação para a rejeição."
            });
        }

        var observation =
            await _context.Observations
                .FindAsync(id);

        if (observation == null)
        {
            return NotFound(new
            {
                message =
                    "Observação não encontrada."
            });
        }

        if (observation.Status != "Pending")
        {
            return BadRequest(new
            {
                message =
                    "Esta observação já foi processada."
            });
        }

        var userIdClaim =
            User.FindFirstValue(
                ClaimTypes.NameIdentifier
            );

        if (!int.TryParse(
            userIdClaim,
            out var validatorId))
        {
            return Unauthorized();
        }

        observation.Status =
            "Rejected";

        observation.RejectionReason =
            request.Reason.Trim();

        observation.ValidationNotes =
            request.Notes?.Trim();

        observation.ValidatedByUserId =
            validatorId;

        observation.ValidatedAt =
            DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new
        {
            message =
                "Observação rejeitada com sucesso."
        });
    }

    // GET api/Validation/stats
    [HttpGet("stats")]
    public async Task<IActionResult> GetValidatorStats()
    {
        var userIdClaim =
            User.FindFirstValue(
                ClaimTypes.NameIdentifier
            );

        if (!int.TryParse(
            userIdClaim,
            out var validatorId))
        {
            return Unauthorized();
        }

        // Total de observações atualmente
        // disponíveis para validação
        var pending =
            await _context.Observations
                .CountAsync(
                    o => o.Status == "Pending"
                );

        // Observações validadas
        // pelo técnico autenticado
        var validated =
            await _context.Observations
                .CountAsync(
                    o =>
                        o.Status == "Validated" &&
                        o.ValidatedByUserId ==
                            validatorId
                );

        // Observações rejeitadas
        // pelo técnico autenticado
        var rejected =
            await _context.Observations
                .CountAsync(
                    o =>
                        o.Status == "Rejected" &&
                        o.ValidatedByUserId ==
                            validatorId
                );

        var totalProcessed =
            validated + rejected;

        return Ok(new
        {
            pending,
            validated,
            rejected,
            totalProcessed
        });
    }
    // GET api/Validation/history
[HttpGet("history")]
public async Task<IActionResult> GetValidationHistory()
{
    var userIdClaim =
        User.FindFirstValue(
            ClaimTypes.NameIdentifier
        );

    if (!int.TryParse(
        userIdClaim,
        out var validatorId))
    {
        return Unauthorized();
    }

    var history =
        await _context.Observations
            .Where(o =>
                o.ValidatedByUserId ==
                    validatorId &&
                (o.Status == "Validated" ||
                 o.Status == "Rejected"))
            .OrderByDescending(
                o => o.ValidatedAt
            )
            .Select(o => new
            {
                o.Id,
                o.CommonName,
                o.ScientificName,
                o.Status,
                o.ImageUrl,
                o.ValidationNotes,
                o.RejectionReason,
                o.ValidatedAt
            })
            .ToListAsync();

    return Ok(history);
}
}