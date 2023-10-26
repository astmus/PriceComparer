using System.Collections.Generic;
using System.Linq;

using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Models;
using Comparer.DataAccess.Repositories;

using LinqToDB;
using LinqToDB.AspNet;
using LinqToDB.AspNet.Logging;

using Microsoft.Extensions.DependencyInjection;

namespace Comparer.DataAccess
{
	public static class ServiceCollectionExtensions
	{
		public static IServiceCollection AddDataBaseRepositories(this IServiceCollection collection)
			=> collection.AddLinqToDBContext<DataBaseConnection>((provider, options)
				=> options
					.UseDefaultLogging(provider))
					.AddScoped<IPriceListRepository, PriceListRepository>()
					.AddScoped<IDistributorRepository, DistributorRepository>()
					.AddScoped<IProductRepository, ProductRepository>();
	}
}
