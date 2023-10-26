
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Comparer.DataAccess.Dto;

using Refit;

namespace Comparer.DataAccess.Rest
{
	public interface IDistributorRestClient : IRestClient<Distributor>
	{
		[GetApi<Distributor>]
		Task<ApiResponse<IEnumerable<DistributorInfo>>> GetAllAsync();


		[GetApi<Distributor>]
		Task<ApiResponse<IAsyncEnumerable<Distributor>>> GetAllStream();

		[GetApi<Distributor>("{distributor.Id}", "prices")]
		Task<ApiResponse<IEnumerable<DistributorPriceDto>>> PriceListsOf(DistributorInfo distributor);
	}
}
