namespace Comparer.ApiClient
{
	public interface IApiClientProvider
	{
		T GetClient<T>();
	}
}
