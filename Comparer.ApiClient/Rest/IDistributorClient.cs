
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Comparer.DataAccess.Dto;

using Refit;

namespace Comparer.DataAccess.Rest
{
	public interface IDistributorRestClient : IRestClient
	{
		[Get("/")]
		Task<IEnumerable<DistributorData>> GetAllAsync();

		[Get("/{distributor.Id}/prices")]
		Task<ApiResponse<IEnumerable<DistributorPriceListData>>> PriceListsAsync(DistributorData distributor);
	}
}
