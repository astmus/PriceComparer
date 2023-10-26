using System;
using System.Collections.Generic;
using System.Text;



using Refit;

namespace Comparer.ApiClient.Rest
{
	class RestClientProvider : IRestClientProvider
	{
		private readonly Uri baseUri;

		public RestClientProvider(string apiUrl)
		{
			baseUri = new Uri(apiUrl);
		}
		public T GetClient<T>()
			=> RestService.For<T>(baseUri.ToString());
		public IDistributorRestClient Distributors
		=> ComparerApi.ClientProvider.GetClient<IDistributorRestClient>();
		public IPriceListRestClient PriceLists
			=> ComparerApi.ClientProvider.GetClient<IPriceListRestClient>();
	}
}
