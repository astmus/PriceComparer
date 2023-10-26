
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Comparer.DataAccess.Dto;

using Refit;

namespace Comparer.DataAccess.Rest
{
	public interface IPriceListRestClient : IRestClient<PriceListDto>
	{
		[GetApi("pricelist/{id}/items")]
		Task<ApiResponse<IEnumerable<PriceListItem>>> ItemsAsync([AliasAs("id")] Guid priceListId);

		[Get("/products/{product}")]
		Task<IEnumerable<ProductInfo>> ProductsAsync([AliasAs("product")] Guid productId);
	}
}
