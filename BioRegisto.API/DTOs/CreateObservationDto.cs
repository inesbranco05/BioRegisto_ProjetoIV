namespace BioRegisto.API.DTOs;

public class CreateObservationDto
{
    public string ScientificName { get; set; } = string.Empty;

    public string CommonName { get; set; } = string.Empty;

    public string Latitude { get; set; }

    public string Longitude { get; set; }

    public IFormFile? Image { get; set; }
}