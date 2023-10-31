
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Comparer.DataAccess.Abstractions;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Requests;

using Refit;

namespace Comparer.DataAccess.Rest
{
	public interface IProductRestClient : IRestClient
	{
		[Get("/{id}")]
		Task<IEnumerable<ProductInfo>> FindAllAsync([AliasAs("id")] Guid productId);
		[Get("/{id}")]
		Task<IEnumerable<TProduct>> FindAllAsync<TProduct>([AliasAs("id")] Guid productId, PriceListItem info) where TProduct : ProductInfo;

		[Get("/diff")]
		Task<IEnumerable<PriceListProductDiffItem>> AnalizeAsync([AliasAs("id")] CompareRequest request);

		[Get("/{id}/select")]
		Task<IEnumerable<string>> SelectAsync([AliasAs("id")] Guid productId, params object[] fields);
	}
}
