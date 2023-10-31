using Comparer.Api.Filters;
using Comparer.DataAccess;
using Comparer.DataAccess.Abstractions;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Models;
using Comparer.DataAccess.Queries;
using Comparer.DataAccess.Repositories;

using LinqToDB;

using Microsoft.AspNetCore.Mvc;

namespace Comparer.Api.Controllers
{
	public class ProductController : BaseController
	{

		IProductRepository _repository;
		public ProductController(IProductRepository repository)
		{
			_repository = repository;
		}

		[HttpGet]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IEnumerable<ProductInfo>))]
		public async Task<IEnumerable<ItemInfo<Guid>>> GetAllAsync()
		{
			var products = await _repository.FromRaw<ItemInfo<Guid>>().ToListAsync();
			return products;
		}

		[HttpGet("{id}")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status404NotFound)]
		[ProducesResponseType(StatusCodes.Status204NoContent)]
		public async Task<ActionResult<IEnumerable<PriceProductInfo>>> Get([FromRoute(Name = "id")] Guid productId, [FromQuery] ProductInfo info)
		{
			_log.LogDebug("Producst" + productId + "Get");
			if (await _repository.ContainItemAsync(dist => dist.ID == productId))
			{
				var pricesProducts = await _repository.GetPriceProductsAsync(productId, info);
				if (!pricesProducts.Any())
					return NoContent();


				return Ok(pricesProducts);
			}
			else
				return NotFound("Product does not exist");
		}

		public Task<IEnumerable<string>> SelectAsync(Guid productId, params object[] fields) => throw new NotImplementedException();


		[HttpGet("[action]/{baseListId:guid}")]
		//[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IAsyncEnumerable<PriceListProductDiffItem>))]
		public async Task<IEnumerable<ProductInfo>> FindAsync(Guid productId)

		{
			//if (!await _repository.ContainItemAsync(f => f.ID == productId))
			//	ThrowClient(StatusCodes.Status400BadRequest, "Wrong base price list");
			var res = await _repository.FromRaw<ProductInfo>().Take(100).ToListAsync();
			return res;
			//var l = _repository.Products.Where(f => f.PriceListId == baseListId).ToList();
			//var baseList = _repository.PriceListProducts.Where(f => f.PriceListId == baseListId).ToDictionary(d => d.ProductId);

			//var allListsProducts = (from rec in _repository.PRICESRECORDS
			//						join link in _repository.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
			//						join prod in _repository.PRODUCTS on link.CATALOGPRODUCTID equals prod.ID
			//						join list in _repository.PRICES on rec.PRICEID equals list.ID
			//						join dist in _repository.DISTRIBUTORS on list.DISID equals dist.ID
			//						where list.ISACTIVE && dist.ACTIVE && list.ID != baseListId && !prod.DELETED && rec.USED && !rec.DELETED && baseList.ContainsKey(prod.ID)
			//						select new PriceListProductDiffItem()
			//						{
			//							ProductId = prod.ID,
			//							ItemName = list.NAME,
			//							ProductName = rec.NAME,
			//							Price = rec.PRICE,
			//							DistributorName = dist.NAME,
			//							PriceDiff = prod.PRICE - rec.PRICE
			//						}
			//					  );

			//await foreach (var item in allListsProducts.AsAsyncEnumerable())
			//	yield return item;
		}

		public Task<IEnumerable<PriceProductInfo>> FindAsync(Guid productId, [FromQuery] ProductInfo info) => throw new NotImplementedException();
		public Task<IEnumerable<DisributorPriceProductInfo>> FindAsync(Guid productId, [FromQuery] PriceProductInfo info) => throw new NotImplementedException();
	}
}