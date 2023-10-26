using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using System.Windows;

using Comparer.DataAccess;

using Refit;

namespace Comparer.DesktopClient
{
	/// <summary>
	/// Interaction logic for App.xaml
	/// </summary>
	public partial class App : Application
	{
		protected override void OnStartup(StartupEventArgs e)
		{
			base.OnStartup(e);

			var options = new JsonSerializerOptions(JsonSerializerDefaults.Web);
			options.ReferenceHandler = ReferenceHandler.Preserve;
			options.IncludeFields = true;
			options.PropertyNameCaseInsensitive = false;

			ApiClient.CreateClientProvider("http://localhost:5078"
			, new Refit.RefitSettings()
			{
				ContentSerializer = new SystemTextJsonContentSerializer(options)
				//CollectionFormat = Refit.CollectionFormat.Multi,
				//ExceptionFactory = response => new Task<Exception?>(() => new Exception(JsonSerializer.Serialize(response)))
			}
			);
		}
	}
}
