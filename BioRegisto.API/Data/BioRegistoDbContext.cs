using Microsoft.EntityFrameworkCore;
using BioRegisto.API.Models;

namespace BioRegisto.API.Data;

public class BioRegistoDbContext : DbContext
{
    public BioRegistoDbContext(
        DbContextOptions<BioRegistoDbContext> options
    ) : base(options)
    {
    }

    public DbSet<Observation> Observations =>
        Set<Observation>();
}