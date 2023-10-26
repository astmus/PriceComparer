namespace Comparer.ApiClient.Rest
{
	public interface IRestClientProvider : IApiClientProvider
	{
		IDistributorRestClient Distributors { get; }
		IPriceListRestClient PriceLists { get; }
	}
}
