using Comparer.DataAccess.Rest;

using Refit;

namespace Comparer.DataAccess
{
	public static class ApiClient
	{
		public static class Rest
		{
			public static IRestClientProvider ClientProvider
				=> ApiClient.ClientProvider as IRestClientProvider;
		}

		public static IApiClientProvider ClientProvider { get; private set; }
		public static IApiClientProvider CreateClientProvider(string apiUrl, RefitSettings settings = null) => ClientProvider switch
		{
			not null when settings is null => new RestClientProvider(apiUrl),
			not null when settings is not null => new RestClientProvider(apiUrl, settings),
			_ => ClientProvider = new RestClientProvider(apiUrl, settings)
		};
	}
}
