
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Comparer.Dto;

using Refit;

namespace Comparer.ApiClient.Rest
{
	public interface IDistributorRestClient : IRestClient<Distributor>
	{
		[GetApi<Distributor>]
		Task<IEnumerable<Distributor>> GetAllAsync();

		//[GetApi<Distributor>("{id}")]
		//Task<Distributor> GetByCriteriaAsync(Guid id, Distributor? criteria);

		[GetApi<Distributor>]
		Task<ApiResponse<IAsyncEnumerable<Distributor>>> GetAllStream();

		[GetApi<Distributor, string>("{id}", nameof(PriceLists))]
		Task<ApiResponse<IAsyncEnumerable<PriceList>>> PriceLists([AliasAs("id")] Guid distributorId);
	}
}
