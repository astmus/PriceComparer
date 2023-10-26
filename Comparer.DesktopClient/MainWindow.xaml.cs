using System.Collections.ObjectModel;
using System.Windows;

using Comparer.ApiClient;
using Comparer.ApiClient.Queries;
using Comparer.DesktopClient.ViewModels;
using Comparer.Dto;

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
			ComparerApi.CreateClientProvider("http://localhost:5078");
			DataContext = viewModel = new MainWindowViewModel(ComparerApi.Rest.ClientProvider);
		}


		public CompareQuery AnalizeQuery { get; set; } = new CompareQuery();
		public ObservableCollection<PriceListItem> CurrentPriceListItems { get; set; } = new ObservableCollection<PriceListItem>();


		Distributor? CurrentDistributor
			=> distributorsListComboBox.SelectedItem as Distributor;

		ObservableCollection<PriceList> PricesLists { get; set; } = new ObservableCollection<PriceList>();
		ObservableCollection<PriceListProduct> PriceListProducts { get; set; } = new ObservableCollection<PriceListProduct>();
	}
}
