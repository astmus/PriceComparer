
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
		Task<IEnumerable<Tuple<Guid, string>>> GetAllAsync();

		[Get("/{id}")]
		Task<Tuple<ID>> InfoAsync<ID>([AliasAs("id")] Guid priceId) where ID : class;

		[Get("/{id}/content")]
		Task<PriceListDto> ContentAsync([AliasAs("id")] Guid id);

		[Get("/{id}/items")]
		Task<ApiResponse<IEnumerable<TPLitem>>> ItemsAsync<TPLitem>([AliasAs("id")] Guid priceListId) where TPLitem : PriceListItem;

		[Get("/{id}/products")]
		Task<IEnumerable<ProductInfo>> ProductsAsync([AliasAs("id")] Guid productId);

	}
}
