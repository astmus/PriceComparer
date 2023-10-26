using Comparer.ApiClient.Rest;

namespace Comparer.ApiClient
{
	public static class ComparerApi
	{
		public static class Rest
		{
			public static IRestClientProvider ClientProvider
				=> ComparerApi.ClientProvider as IRestClientProvider;
		}

		public static IApiClientProvider ClientProvider { get; private set; }
		public static IApiClientProvider CreateClientProvider(string apiUrl) => ClientProvider switch
		{
			not null => new RestClientProvider(apiUrl),
			_ => ClientProvider = new RestClientProvider(apiUrl)
		};
	}
}
