
using Comparer.Api.Filters;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Repositories;

using LinqToDB;

using Microsoft.AspNetCore.Mvc;

namespace Comparer.Api.Controllers
{
	public class DistributorController : BaseController
	{

		IDistributorRepository _repository;
		public DistributorController(IDistributorRepository repository)
		{
			_repository = repository;
		}

		protected override ILogger log
			=> GetLogger<DistributorController>();

		[HttpGet]
		[SerializationFilter]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IEnumerable<DistributorData>))]
		[ProducesResponseType(StatusCodes.Status204NoContent, Type = typeof(IEnumerable<DistributorData>))]
		public async Task<ActionResult<IEnumerable<DistributorData>>> Get()
		{
			var distributors = await _repository.RawQuery<DistributorData>().ToListAsync();
			LogInfo($"Distributors count: {distributors.Count}");
			if (!distributors.Any())
				return NoContent();
			return Ok(distributors);
		}

		[HttpGet("{id}")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status404NotFound)]
		public async Task<ActionResult<DistributorData>> Get(Guid id)
		{
			if (await _repository.RawQuery<DistributorData>().FirstOrDefaultAsync(dist => dist.Id == id) is DistributorData distResult)
				return Ok(distResult);
			else
				return NotFound("Distributor does not exist");
		}

		[HttpGet("{id:guid}/prices")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IEnumerable<DistributorPriceListDto>))]
		[ProducesResponseType(typeof(IEnumerable<DistributorPriceListDto>), StatusCodes.Status404NotFound)]
		public async Task<IActionResult> PriceLists(Guid Id)
		{
			var inf = _repository.RawQuery<DistributorData>().FirstOrDefault(f => f.Id == Id);

			if (inf != null)
			{
				var result = await _repository.PriceListsAsync(inf);
				return Ok(result);
			}
			else
				return NotFound("Distributor not found");
		}
	}
	public record DistributorRequest([FromRoute(Name = "id")] Guid Id = default, string? Name = default)
	{
	}
}