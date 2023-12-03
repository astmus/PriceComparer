using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

using Microsoft.Extensions.DependencyInjection;

namespace Comparer.WFDesktopClient
{
	internal static class Program
	{
		public static readonly IServiceProvider Services;

		static Program()
		{
			ServiceCollection services = new ServiceCollection();
			services.AddSingleton<MainForm>();
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
			Application.Run(Services.GetRequiredService<MainForm>());
		}
	}
}
