using System;
using System.Windows.Forms;

using Comparer.DataAccess;

using Microsoft.Extensions.DependencyInjection;

namespace Comparer.WFDesktopClient
{
	internal static class Program
	{
		static readonly IServiceProvider Services;

		static Program()
		{
			ServiceCollection services = new ServiceCollection();
			services.AddSingleton<MainForm>();

			services.AddDataBaseRepositories("Data Source=DS-FUTARK;Initial Catalog=test;Integrated Security=True;Connect Timeout=30;Encrypt=False");

			Services = services.BuildServiceProvider();
		}

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main()
		{
			Application.EnableVisualStyles();
			Application.SetCompatibleTextRenderingDefault(false);
			using (var scope = Services.CreateScope())
				Application.Run(scope.ServiceProvider.GetRequiredService<MainForm>());
		}
	}
}
