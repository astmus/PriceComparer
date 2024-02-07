using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Repositories;
using Comparer.CollectionExtensions;
using LinqToDB;

using Microsoft.AspNetCore.Mvc;

namespace Comparer.Api.Controllers
{
	public class DistributorController : BaseController
	{
		IDistributorRepository _repository;
		public DistributorController(IDistributorRepository repository) : base(repository)
		{
			_repository = repository;
		}

		protected override ILogger log
			=> GetLogger<DistributorController>();

		[HttpGet("{id}")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
		[ProducesDefaultResponseType]
		public async Task<ActionResult<DistributorData>> Get(Guid id)
		{
			if (await _repository.RawQuery<DistributorData>().FirstOrDefaultAsync(dist => dist.Id == id) is DistributorData distResult)
				return Ok(distResult);
			else
				return BadRequest("Distributor does not exist");
		}

		[HttpGet("{id:guid}/prices")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IEnumerable<DistributorPriceListDto>))]
		[ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
		[ProducesResponseType(StatusCodes.Status204NoContent)]
		[ProducesDefaultResponseType]
		public async Task<IActionResult> PriceLists(Guid Id)
		{
			using var cancel = OperationCancelling;

			if (await _repository.RawQuery<DistributorData>().FirstOrDefaultAsync(f => f.Id == Id, cancel.Token) is DistributorData data)
			{
				var result = await _repository.PriceListsAsync(data, cancel.Token);
				if (result.IsEmpty())
					return NoContent();

				return Ok(result);
			}
			else
				return BadRequest("Distributor does not exist");
		}
	}
}