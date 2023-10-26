using System.Text.Json;

using Comparer.Api.Filters;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Repositories;

using LinqToDB;

using Microsoft.AspNetCore.Mvc;

namespace Comparer.Api.Controllers
{

	public class PriceListController : BaseController
	{
		private readonly ILogger<PriceListController> _logger;
		IPriceListRepository _repository;
		public PriceListController(ILogger<PriceListController> logger, IPriceListRepository repositroy)
		{
			_logger = logger;
			_repository = repositroy;
		}

		[HttpGet]
		[ProducesResponseType(StatusCodes.Status200OK)]
		public ActionResult<IAsyncEnumerable<ItemInfo<Guid>>> Get()
		{
			var items = _repository.Request().Select(p => new ItemInfo<Guid>(p.ID, p.NAME)).AsAsyncEnumerable();
			return Ok(items);
		}

		[HttpGet("{id}")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(PriceInfo))]
		[ProducesResponseType(StatusCodes.Status400BadRequest)]
		public async Task<IActionResult> Get([FromRoute(Name = "id")] Guid priceListId)
		{
			if (await _repository.FromRaw<PriceInfo>().FirstOrDefaultAsync(list => list.Id == priceListId) is PriceInfo info)
				return Ok(info);
			else
			{
				_logger.LogError($"Price list with id {priceListId} does not exist");
				return BadRequest("Wrong price list id");
			}
		}

		[HttpGet("{id}/[action]")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IAsyncEnumerable<PriceListItem>))]
		[ProducesResponseType(StatusCodes.Status400BadRequest)]
		public async IAsyncEnumerable<PriceListItem> Items([FromRoute(Name = "id")] Guid priceListId)
		{
			if (!await _repository.ContainItemAsync(list => list.ID == priceListId))
			{
				ThrowClient(StatusCodes.Status400BadRequest, "Price list does not exist");
				yield break;
			}

			using var cancel = OperationCancelling;

			await foreach (var item in _repository.Items(priceListId).WithCancellation(cancel.Token))
				yield return item;
		}

		[HttpGet("{id}/[action]")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(PriceListDto))]
		[ProducesResponseType(StatusCodes.Status400BadRequest)]
		public async Task<IActionResult> Content([FromRoute(Name = "id")] Guid priceListId)
		{
			using var cancel = OperationCancelling;

			var result = await _repository.WithContentAsync(priceListId);

			if (result == null)
				return BadRequest($"Price list with id {priceListId} does not exist");

			return Ok(result);
		}

		//[HttpGet("[action]/{baseListId:guid}")]
		//[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IAsyncEnumerable<PriceListProductDiffItem>))]
		//[ProducesResponseType(statusCode: StatusCodes.Status400BadRequest, contentType: MediaTypeNames.Text.Plain, type: typeof(IAsyncEnumerable<PriceListProductDiffItem>))]
		//public async IAsyncEnumerable<PriceListProductDiffItem> Diff(Guid baseListId)
		//{
		//	if (!_repository.PRICES.Any(f => f.ID == baseListId))
		//	{
		//		Response.StatusCode = StatusCodes.Status400BadRequest;
		//		await Response.WriteAsync("Wrong baseListId");
		//		yield break;
		//	}

		//	var l = _repository.PriceListProducts.Where(f => f.PriceListId == baseListId).ToList();
		//	var baseList = _repository.PriceListProducts.Where(f => f.PriceListId == baseListId).ToDictionary(d => d.ProductId);

		//	var allListsProducts = (from rec in _repository.PRICESRECORDS
		//							join link in _repository.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
		//							join prod in _repository.PRODUCTS on link.CATALOGPRODUCTID equals prod.ID
		//							join list in _repository.PRICES on rec.PRICEID equals list.ID
		//							join dist in _repository.DISTRIBUTORS on list.DISID equals dist.ID
		//							where list.ISACTIVE && dist.ACTIVE && list.ID != baseListId && !prod.DELETED && rec.USED && !rec.DELETED && baseList.ContainsKey(prod.ID)
		//							select new PriceListProductDiffItem()
		//							{
		//								ProductId = prod.ID,
		//								ItemName = list.NAME,
		//								ProductName = rec.NAME,
		//								Price = rec.PRICE,
		//								DistributorName = dist.NAME,
		//								PriceDiff = prod.PRICE - rec.PRICE
		//							}
		//						  );

		//	await foreach (var item in allListsProducts.AsAsyncEnumerable())
		//		yield return item;
		//}
	}
}