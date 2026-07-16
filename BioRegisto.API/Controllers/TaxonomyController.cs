using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BioRegisto.API.Data;
using BioRegisto.API.DTOs;
using BioRegisto.API.Models;

namespace BioRegisto.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Validator,Admin")]
public class TaxonomyController : ControllerBase
{
    private readonly BioRegistoDbContext _context;

    public TaxonomyController(
        BioRegistoDbContext context)
    {
        _context = context;
    }

    // GET api/Taxonomy/roots
    // Devolve os táxons sem pai, normalmente os Reinos.
    [HttpGet("roots")]
    public async Task<IActionResult> GetRoots()
    {
        var taxa = await _context.Taxa
            .Where(t => t.ParentId == null)
            .OrderBy(t => t.Name)
            .Select(t => new
            {
                t.Id,
                t.Name,
                t.Rank,
                t.ParentId
            })
            .ToListAsync();

        return Ok(taxa);
    }

    // GET api/Taxonomy/{parentId}/children
    // Devolve o nível taxonómico seguinte.
    [HttpGet("{parentId}/children")]
    public async Task<IActionResult> GetChildren(
        int parentId)
    {
        var parentExists =
            await _context.Taxa.AnyAsync(
                t => t.Id == parentId
            );

        if (!parentExists)
        {
            return NotFound(
                new
                {
                    message =
                        "Táxon não encontrado."
                }
            );
        }

        var children = await _context.Taxa
            .Where(t =>
                t.ParentId == parentId)
            .OrderBy(t => t.Name)
            .Select(t => new
            {
                t.Id,
                t.Name,
                t.Rank,
                t.ParentId
            })
            .ToListAsync();

        return Ok(children);
    }

    // GET api/Taxonomy/{id}
    // Devolve os dados de um táxon específico.
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(
        int id)
    {
        var taxon = await _context.Taxa
            .Where(t => t.Id == id)
            .Select(t => new
            {
                t.Id,
                t.Name,
                t.Rank,
                t.ParentId
            })
            .FirstOrDefaultAsync();

        if (taxon == null)
        {
            return NotFound(
                new
                {
                    message =
                        "Táxon não encontrado."
                }
            );
        }

        return Ok(taxon);
    }

    // POST api/Taxonomy
[HttpPost]
public async Task<IActionResult> Create(
    CreateTaxonDto request)
{
    if (string.IsNullOrWhiteSpace(request.Name))
    {
        return BadRequest(new
        {
            message = "O nome é obrigatório."
        });
    }

    var validRanks = new[]
    {
        "Kingdom",
        "Phylum",
        "Class",
        "Order",
        "Family",
        "Genus",
        "Species"
    };

    if (!validRanks.Contains(request.Rank))
    {
        return BadRequest(new
        {
            message =
                "O nível taxonómico não é válido."
        });
    }

    Taxon? parent = null;

    if (request.ParentId != null)
    {
        parent = await _context.Taxa
            .FindAsync(request.ParentId);

        if (parent == null)
        {
            return BadRequest(new
            {
                message =
                    "O táxon superior não existe."
            });
        }
    }

  // Um Reino não deve ter pai.
if (request.Rank == "Kingdom" &&
    request.ParentId != null)
{
    return BadRequest(new
    {
        message =
            "Um Reino não pode ter um táxon superior."
    });
}

// Define qual deve ser o nível superior
// de cada nível taxonómico.
var hierarchy =
    new Dictionary<string, string?>
    {
        { "Kingdom", null },
        { "Phylum", "Kingdom" },
        { "Class", "Phylum" },
        { "Order", "Class" },
        { "Family", "Order" },
        { "Genus", "Family" },
        { "Species", "Genus" }
    };

var expectedParentRank =
    hierarchy[request.Rank];

// Verifica se o pai selecionado
// pertence ao nível correto.
if (expectedParentRank != null &&
    parent?.Rank != expectedParentRank)
{
    return BadRequest(new
    {
        message =
            $"Um táxon do nível {request.Rank} deve pertencer a um táxon do nível {expectedParentRank}."
    });
}

// Só depois das validações
// é criado o novo táxon.
var taxon = new Taxon
{
    Name = request.Name.Trim(),
    Rank = request.Rank,
    ParentId = request.ParentId
};

    _context.Taxa.Add(taxon);

    await _context.SaveChangesAsync();

    return Ok(new
    {
        taxon.Id,
        taxon.Name,
        taxon.Rank,
        taxon.ParentId
    });
}

// PUT api/Taxonomy/{id}
[HttpPut("{id:int}")]
public async Task<IActionResult> Update(
    int id,
    UpdateTaxonDto request)
{
    if (string.IsNullOrWhiteSpace(
        request.Name))
    {
        return BadRequest(new
        {
            message =
                "O nome é obrigatório."
        });
    }

    var taxon =
        await _context.Taxa.FindAsync(id);

    if (taxon == null)
    {
        return NotFound(new
        {
            message =
                "Táxon não encontrado."
        });
    }

    taxon.Name =
        request.Name.Trim();

    await _context.SaveChangesAsync();

    return Ok(new
    {
        taxon.Id,
        taxon.Name,
        taxon.Rank,
        taxon.ParentId
    });
}

}