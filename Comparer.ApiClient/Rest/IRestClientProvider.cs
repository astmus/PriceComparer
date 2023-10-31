namespace Comparer.DataAccess.Rest
{
	public interface IRestClientProvider
	{
		IDistributorRestClient Distributors { get; }
		IPriceListRestClient PriceLists { get; }
		IProductRestClient Products { get; }
	}
}
