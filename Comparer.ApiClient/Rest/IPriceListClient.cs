
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Comparer.Dto;

using Refit;

namespace Comparer.ApiClient.Rest
{
	public interface IPriceListRestClient : IRestClient<PriceList>
	{
		[Get("/{id}/Items")]
		Task<IEnumerable<PriceListItem>> ItemsAsync([AliasAs("id")] Guid priceListId);

		[Get("/Products/{product}")]
		Task<IEnumerable<PriceListProduct>> ProductsAsync([AliasAs("product")] Guid productId);
	}
}
