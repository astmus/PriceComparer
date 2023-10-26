namespace Comparer.DataAccess
{
	public interface IApiClientProvider
	{
		T GetClient<T>();
	}
}
