
using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;

using Comparer.DataAccess.Dto;

using Refit;

namespace Comparer.DataAccess.Rest
{
	public interface IRestClient
	{ }
	public interface IPriceListRestClient : IRestClient
	{
		[Get("/")]
		Task<IEnumerable<ItemInfo<Guid>>> GetAllAsync();

		[Get("/{id}")]
		Task<ObjectInfo<TInfo>> InfoAsync<TInfo>([AliasAs("id")] Guid priceId) where TInfo : class;

		[Get("/{id}/content")]
		Task<PriceListDto> ContentAsync([AliasAs("id")] Guid id);

		[Get("/{id}/items")]
		Task<ApiResponse<IEnumerable<TItem>>> ItemsAsync<TItem>([AliasAs("id")] Guid priceListId) where TItem : PriceListItem;

		[Get("/{id}/products")]
		Task<IEnumerable<ProductInfo>> ProductsAsync([AliasAs("id")] Guid productId);

	}
}
