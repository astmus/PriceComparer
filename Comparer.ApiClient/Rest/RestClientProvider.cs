using System;
using System.Collections.Generic;
using System.Text;



using Refit;

namespace Comparer.DataAccess.Rest
{
	class RestClientProvider : IRestClientProvider
	{
		private readonly Uri baseUri;
		RefitSettings? settings;
		public RestClientProvider(string apiUrl, RefitSettings settings = null)
		{
			baseUri = new Uri(apiUrl);
			this.settings = settings;
		}
		public T GetClient<T>()
			=> RestService.For<T>(baseUri.ToString(), settings);
		public IDistributorRestClient Distributors
		=> ApiClient.ClientProvider.GetClient<IDistributorRestClient>();
		public IPriceListRestClient PriceLists
			=> ApiClient.ClientProvider.GetClient<IPriceListRestClient>();
	}
}
