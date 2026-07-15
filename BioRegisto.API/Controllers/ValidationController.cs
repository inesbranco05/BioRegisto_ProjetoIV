using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BioRegisto.API.Data;
using BioRegisto.API.DTOs;

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
            return NotFound(
                new
                {
                    message =
                        "Observação não encontrada."
                }
            );
        }

        if (observation.Status != "Pending")
        {
            return BadRequest(
                new
                {
                    message =
                        "Esta observação já foi processada."
                }
            );
        }

        var taxon =
            await _context.Taxa
                .FindAsync(request.TaxonId);

        if (taxon == null)
        {
            return BadRequest(
                new
                {
                    message =
                        "O táxon selecionado não existe."
                }
            );
        }

        if (taxon.Rank != "Species")
        {
            return BadRequest(
                new
                {
                    message =
                        "A classificação final deve corresponder a uma espécie."
                }
            );
        }

        observation.TaxonId =
            taxon.Id;

        observation.Status =
            "Validated";

        await _context.SaveChangesAsync();

        return Ok(
            new
            {
                message =
                    "Observação validada com sucesso."
            }
        );
    }

    // PUT api/Validation/{id}/reject
    [HttpPut("{id}/reject")]
    public async Task<IActionResult> Reject(
        int id)
    {
        var observation =
            await _context.Observations
                .FindAsync(id);

        if (observation == null)
        {
            return NotFound(
                new
                {
                    message =
                        "Observação não encontrada."
                }
            );
        }

        if (observation.Status != "Pending")
        {
            return BadRequest(
                new
                {
                    message =
                        "Esta observação já foi processada."
                }
            );
        }

        observation.Status =
            "Rejected";

        await _context.SaveChangesAsync();

        return Ok(
            new
            {
                message =
                    "Observação rejeitada."
            }
        );
    }
}