using System.Collections.ObjectModel;
using System.Windows;

using Comparer.DataAccess;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Queries;
using Comparer.DesktopClient.ViewModels;

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

			DataContext = viewModel = new MainWindowViewModel(ApiClient.Rest.ClientProvider);
		}
	}
}
