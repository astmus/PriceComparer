using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Serialization;

using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Config;
using Comparer.DataAccess.Models;
using Comparer.DataAccess.Repositories;
using Comparer.DataAccess.Rest;

using LinqToDB;
using LinqToDB.AspNet;
using LinqToDB.AspNet.Logging;

using Microsoft.Extensions.DependencyInjection;

using Refit;

namespace Comparer.DataAccess
{
	public static class ServiceCollectionExtensions
	{
		static JsonSerializerOptions serializeOptions = new JsonSerializerOptions(JsonSerializerDefaults.Web)
		{
			ReferenceHandler = ReferenceHandler.Preserve,
			IncludeFields = true,
			PropertyNameCaseInsensitive = true,
		};
		static RefitSettings refitOptions = new Refit.RefitSettings()
		{
			ContentSerializer = new SystemTextJsonContentSerializer(serializeOptions)
		};

		public static IServiceCollection AddDataBaseRepositories(this IServiceCollection collection, string defaultAddress = null)
		{
			if (defaultAddress != null)
				collection.AddOptions<ConnectionOptions>().Configure(opt => opt.ConnectionString = defaultAddress);

			return collection.AddLogging().AddLinqToDBContext<DataBaseConnection>((provider, options)
				=> options
					.UseDefaultLogging(provider))
					.AddScoped<IPriceListRepository, PriceListRepository>()
					.AddScoped<IDistributorRepository, DistributorRepository>()
					.AddScoped<IProductRepository, ProductRepository>();
		}

		public static IServiceCollection AddRestClientFor<TPoint>(this IServiceCollection collection, string address) where TPoint : class, IRestClient
		{
			collection.AddRefitClient<TPoint>(refitOptions).ConfigureHttpClient(c => c.BaseAddress = new Uri(address));
			return collection;
		}
	}
}
