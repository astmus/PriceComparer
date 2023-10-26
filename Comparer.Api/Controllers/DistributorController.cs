using Comparer.Api.Filters;
using Comparer.DataAccess;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Models;
using Comparer.DataAccess.Repositories;

using LinqToDB;

using Microsoft.AspNetCore.Mvc;

namespace Comparer.Api.Controllers
{
	public class DistributorController : BaseController
	{
		private readonly ILogger<DistributorController> _logger;
		IDistributorRepository _repository;
		public DistributorController(ILogger<DistributorController> logger, IDistributorRepository repository)
		{
			_logger = logger;
			_repository = repository;
		}

		[HttpGet]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IEnumerable<DistributorInfo>))]
		[ProducesResponseType(StatusCodes.Status204NoContent, Type = typeof(IEnumerable<DistributorInfo>))]
		public async Task<IActionResult> Get()
		{
			var distributors = await _repository.FromRaw<DistributorInfo>().ToListAsync();
			if (!distributors.Any())
				return NoContent();
			return Ok(distributors);
		}

		[HttpGet("{id}")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status400BadRequest)]
		public async Task<ActionResult<Distributor>> Get(Guid id)
		{
			if (await _repository.ContainItemAsync(dist => dist.ID == id))
			{
				var distResult = _repository.FromRaw<Distributor>().FirstOrDefault(d => d.Id == id);
				return Ok(distResult);
			}
			else
				return BadRequest("Distributor does not exist");
		}

		[HttpGet("{id}/prices")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IEnumerable<DistributorPriceDto>))]
		[ProducesResponseType(typeof(string), StatusCodes.Status404NotFound)]
		public async Task<IActionResult> PriceLists([FromRoute] Guid id, [FromQuery] DistributorInfo info)
		{
			if (await _repository.ContainItemAsync(dist => dist.ID == id))
			{
				var result = await _repository.PriceListsOf(id, info);
				return Ok(result);
			}
			else
				return NotFound("Distributor not found");
		}
	}
}