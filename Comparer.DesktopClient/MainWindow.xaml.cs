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
		UIViewModel<MainWindow> viewModel;
		public MainWindow()
		{
			InitializeComponent();
			DataContext = viewModel = (App.Current as App).ServicesProvider.GetRequiredService<UIViewModel<MainWindow>>();
			Loaded += (object sender, RoutedEventArgs e)
				=> viewModel.LoadMainDataCommand.Execute(default);
		}
	}
}
