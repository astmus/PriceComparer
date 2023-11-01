using Microsoft.Extensions.DependencyInjection;

namespace Comparer.DataAccess.Rest
{
	public class RestClientProvider : IRestClientProvider
	{
		private readonly IServiceProvider sp;
		public RestClientProvider(IServiceProvider sp)
		{
			this.sp = sp;
		}

		public IDistributorRestClient Distributors
			=> sp.GetRequiredService<IDistributorRestClient>();
		public IPriceListRestClient PriceLists
			=> sp.GetRequiredService<IPriceListRestClient>();
		public IProductRestClient Products
			=> sp.GetRequiredService<IProductRestClient>();
	}
}
