using System.Collections.Generic;
using System.Threading.Tasks;

using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Requests;

using Refit;

namespace Comparer.DataAccess.Rest
{
	public interface IProductRestClient : IRestClient
	{
		[Get("/{id}")]
		Task<IEnumerable<TProduct>> AllAsync<TProduct>([AliasAs("id")] Guid productId, Guid? basePriceId) where TProduct : class, IProductInfoPovider;

		[Get("/diff")]
		Task<IEnumerable<PriceProductDiffDto>> AnalizeAsync([AliasAs("id")] CompareRequest request);
	}
}
