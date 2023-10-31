using System.Windows;

using Comparer.DesktopClient.ViewModels;

using Microsoft.Extensions.DependencyInjection;

namespace Comparer.DesktopClient
{
	/// <summary>
	/// Interaction logic for MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window
	{
		MainWindowViewModel viewModel;
		public MainWindow()
		{
			InitializeComponent();
			DataContext = (App.Current as App).ServicesProvider.GetRequiredService<UIViewModel<MainWindow>>();
		}


	}
}
