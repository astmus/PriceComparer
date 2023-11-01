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
				var pricesProducts = await _repository.GetProductsAsync(productId, info);
				if (!pricesProducts.Any())
					return NoContent();


				return Ok(pricesProducts);
			}
			else
				return NotFound("Product does not exist");
		}


		[HttpGet("diff")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		public async Task<ActionResult<IEnumerable<PriceListProductDiffItem>>> DiffAnalizeAsync([FromQuery] CompareRequest request)
		{

			var baseProducts = _repository.PriceListProducts.Where(w => w.PriceListId == request.BasePriceId);
			var otherProducts = _repository.AvailablePriceListProducts.Where(s => s.PriceListId != request.BasePriceId);

			var diffQuery = from baseProduct in baseProducts
							join otherProduct in otherProducts on baseProduct.Id equals otherProduct.Id
							group otherProduct by otherProduct.Id into gr
							select new ProductDiffItem()
							{
								ProductId = gr.Key,
								MinPrice = gr.Min(prod => prod.Price),
								MaxPrice = gr.Max(prod => prod.Price)
							};

			var resultQuery = from baseProduct in baseProducts
							  join otherProduct in otherProducts on baseProduct.Id equals otherProduct.Id
							  join diff in diffQuery on otherProduct.Id equals diff.ProductId
							  select new PriceListProductDiffItem()
							  {
								  Product = otherProduct,
								  Price = baseProduct.Price,
								  MinPrice = PriceByRequestKinq(baseProduct.Price, diff.MinPrice, request.Kind),
								  MaxPrice = diff.MaxPrice
							  };

			var result = await resultQuery.ToListAsync();
			return result;
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