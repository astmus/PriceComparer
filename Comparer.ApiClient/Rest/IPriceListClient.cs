
using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;

using Comparer.DataAccess.Dto;

using Refit;

namespace Comparer.DataAccess.Rest
{
	public interface IPriceListRestClient : IRestClient
	{
		[Get("/{id}/content")]
		Task<ApiResponse<PriceListDto<TListItem>>> ContentAsync<TListItem>([AliasAs("id")] Guid priceListId) where TListItem : PriceListItem;

		[Get("/{id}/items")]
		Task<ApiResponse<IEnumerable<TPLitem>>> ItemsAsync<TPLitem>([AliasAs("id")] Guid priceListId) where TPLitem : PriceListItem;

		[Get("/{id}/products")]
		Task<IEnumerable<ProductUnit>> ProductsAsync([AliasAs("id")] Guid productId);
	}
}
