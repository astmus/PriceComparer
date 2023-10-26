using Comparer.Api.DataModels;
using Comparer.Dto;

using LinqToDB;

using Microsoft.AspNetCore.Mvc;

namespace Comparer.Api.Controllers
{
	[ApiController]
	[Produces("application/json")]
	[Route("api/[controller]")]
	public class PriceListController : ControllerBase
	{
		private readonly ILogger<PriceListController> _logger;
		DataBaseContext db;
		public PriceListController(ILogger<PriceListController> logger, DataBaseContext db)
		{
			_logger = logger;
			this.db = db;
		}

		[HttpGet("{id}")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(PriceList))]
		[ProducesResponseType(StatusCodes.Status404NotFound)]
		public async Task<IActionResult> Get([FromRoute(Name = "id")] Guid priceListId)
		{
			if (await db.FromSql<PriceList>(nameof(db.PRICES)).FirstOrDefaultAsync(list => list.ID == priceListId) is PriceList info)
				return Ok(info);
			else
			{
				_logger.LogError($"Price list with id {priceListId} does not exist");
				return NotFound("Price list not found");
			}
		}

		[HttpGet("{id}/[action]")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IAsyncEnumerable<PriceListItem>))]
		[ProducesResponseType(StatusCodes.Status404NotFound)]
		public async IAsyncEnumerable<PriceListItem> Items([FromRoute(Name = "id")] Guid priceListId)
		{
			if (await db.PRICES.AnyAsync(list => list.ID == priceListId))
			{
				var items = (from rec in db.PRICESRECORDS
							 join link in db.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
							 join prod in db.PRODUCTS on link.CATALOGPRODUCTID equals prod.ID
							 where rec.PRICEID == priceListId
							 select new PriceListItem()
							 {
								 ItemId = prod.ID,
								 ItemName = rec.NAME,
								 ProductName = $"{prod.NAME} {prod.CHILDNAME}",
								 Price = rec.PRICE
							 }
								).AsAsyncEnumerable();
				await foreach (var item in items)
					yield return item;
			}
		}

		[HttpGet("[action]/{product:guid}")]
		public async IAsyncEnumerable<PriceListProduct> Products([FromRoute(Name = "product")] Guid productId)
		{
			var allProducts = (from rec in db.PRICESRECORDS
							   join link in db.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
							   join prod in db.PRODUCTS on link.CATALOGPRODUCTID equals prod.ID
							   join list in db.PRICES on rec.PRICEID equals list.ID
							   join dist in db.DISTRIBUTORS on list.DISID equals dist.ID
							   where prod.ID == productId
							   select new PriceListProduct()
							   {
								   ProductId = prod.ID,
								   ItemName = list.NAME,
								   ProductName = rec.NAME,
								   Price = rec.PRICE,
								   DistributorName = dist.NAME
							   }
							  ).AsAsyncEnumerable();

			await foreach (var product in allProducts)
				yield return product;

		}
	}
}