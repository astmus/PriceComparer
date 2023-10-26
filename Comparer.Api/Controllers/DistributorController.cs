using Comparer.Api.DataModels;
using Comparer.Dto;

using LinqToDB;

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;

namespace Comparer.Api.Controllers
{
	[ApiController]
	[Produces("text/json")]
	[Route("api/[controller]")]
	public class DistributorController : ControllerBase
	{
		private readonly ILogger<DistributorController> _logger;
		DataBaseContext db;
		public DistributorController(ILogger<DistributorController> logger, DataBaseContext dbContext)
		{
			_logger = logger;
			db = dbContext;
		}

		[HttpGet]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IAsyncEnumerable<Distributor>))]
		public async IAsyncEnumerable<Distributor> Get()
		{
			var queryDist = from dist in db.DISTRIBUTORS
							where dist.ACTIVE == true
							select new Distributor(dist.ID, dist.NAME, dist.ACTIVE);

			await foreach (var d in queryDist.AsAsyncEnumerable())
				yield return d;
		}

		//[HttpGet("{id}{criteria?}")]
		//[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IAsyncEnumerable<Distributor>))]
		//public async IAsyncEnumerable<Distributor> GetByCriteriaAsync(Guid id, [FromQuery] string? criteria)
		//{
		//	var queryDist = from dist in db.DISTRIBUTORS
		//					where dist.ACTIVE == true
		//					select new Distributor(dist.ID, dist.NAME, dist.ACTIVE);

		//	await foreach (var d in queryDist.AsAsyncEnumerable())
		//		yield return d;
		//}

		[HttpGet("{id}")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status404NotFound)]
		public async Task<ActionResult<Distributor>> Get(Guid id)
		{
			if (await db.DISTRIBUTORS.AnyAsync(dist => dist.ID == id))
			{
				var distResult = await db.FromSql<Distributor>(nameof(db.DISTRIBUTORS)).FirstOrDefaultAsync(d => d.Id == id);
				return Ok(distResult);
			}
			else
				return NotFound("Distributor not found");
		}

		[HttpGet("{id}/[action]")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(typeof(string), StatusCodes.Status404NotFound)]
		[ProducesDefaultResponseType]
		public async Task<ActionResult<IAsyncEnumerable<PriceList>>> PriceLists(Guid id)
		{
			if (await db.DISTRIBUTORS.AnyAsync(dist => dist.ID == id))
			{
				var plsQuery = from list in db.PRICES where list.DISID == id select new PriceList(list.ID, list.NAME, list.DISID);
				return Ok(plsQuery.AsAsyncEnumerable());
			}
			else
				return NotFound("Distributor not found");
		}
	}
}