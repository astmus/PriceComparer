using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Repositories;
using Comparer.DataAccess.Requests;

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
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IEnumerable<ProductUnit>))]
		public async Task<IEnumerable<ProductUnit>> GetAllAsync()
		{
			var products = await _repository.RawQuery<ProductUnit>().ToListAsync();
			return products;
		}

		[HttpGet("{id}")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status404NotFound)]
		[ProducesResponseType(StatusCodes.Status204NoContent)]
		public async Task<ActionResult<IEnumerable<PriceListProduct>>> Get([FromRoute(Name = "id")] Guid productId, [FromQuery] PriceListProduct info)
		{
			log.LogDebug("Producst" + productId + "Get");
			using var cancel = OperationCancelling;
			if (await _repository.ItemExistAsync(prod => prod.Id == productId, cancel.Token))
			{
				var pricesProducts = await _repository.PriceListProducts.Where(p => p.Product.Id == productId).ToListAsync(cancel.Token);
				if (!pricesProducts.Any())
					return NoContent();

				return Ok(pricesProducts.OrderBy(o => o.PriceList.Id == info.PriceList.Id ? o.Price : double.MaxValue));
			}
			else
				return NotFound("Product does not exist");
		}


		[HttpGet("diff")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		public async Task<ActionResult<IEnumerable<PriceListProductDiffItem>>> DiffAnalizeAsync([FromQuery] CompareRequest request)
		{
			using var cancel = OperationCancelling;
			var baseProducts = _repository.PriceListProducts.Where(w => w.PriceList.Id == request.BasePriceId);
			var otherProducts = _repository.AvailablePriceListProducts.Where(s => s.PriceList.Id != request.BasePriceId);

			//var diffQuery = from baseProduct in baseProducts
			//				join otherProduct in otherProducts on baseProduct.Id equals otherProduct.Id
			//				group otherProduct by otherProduct.Id into gr
			//				select new PriceListProduct()
			//				{

			//				};

			//var resultQuery = from baseProduct in baseProducts
			//				  join otherProduct in otherProducts on baseProduct.Id equals otherProduct.Id
			//				  select new PriceListProductDiffItem()
			//				  {
			//					  Product = otherProduct,
			//					  Price = baseProduct.Prices.FirstOrDefault()
			//				  };

			//var result = await resultQuery.ToListAsync(cancel.Token);
			await Task.Delay(1);
			return default;
		}

		static double? PriceByRequestKinq(double? price, double? minPrice, CompareKind compare) => compare switch
		{
			CompareKind.OtherMinPrice when minPrice < price => minPrice,
			CompareKind.OtherMinPrice when minPrice > price => default,
			_ => minPrice
		};

		//public Task<IEnumerable<PriceProductInfo>> FindAsync(Guid productId, [FromQuery] ProductInfo info) => throw new NotImplementedException();
		//public Task<IEnumerable<PriceProductInfo>> FindAsync(Guid productId, [FromQuery] PriceProductInfo info) => throw new NotImplementedException();
	}
}