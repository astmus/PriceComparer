using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Navigation;

using Comparer.DataAccess;
using Comparer.DataAccess.Repositories;
using Comparer.DataAccess.Rest;
using Comparer.DesktopClient.ViewModels;

using Microsoft.Extensions.DependencyInjection;

using Refit;

namespace Comparer.DesktopClient
{
	/// <summary>
	/// Interaction logic for App.xaml
	/// </summary>
	public partial class App : Application
	{
		public IServiceProvider ServicesProvider { get; init; }
		public App()
		{
			IServiceCollection Services = new ServiceCollection();
			Services.AddRestClientFor<IPriceListRestClient>("http://localhost:5078/api/pricelist");
			Services.AddRestClientFor<IDistributorRestClient>("http://localhost:5078/api/distributor");
			Services.AddTransient<IRestClientProvider, RestClientProvider>();
			Services.AddTransient<UIViewModel<MainWindow>, MainWindowViewModel>();
			ServicesProvider = Services.BuildServiceProvider();
		}
	}
}
