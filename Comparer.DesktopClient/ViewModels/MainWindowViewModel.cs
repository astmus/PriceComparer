using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using CommunityToolkit.Mvvm.Input;

using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Requests;
using Comparer.DataAccess.Rest;

namespace Comparer.DesktopClient.ViewModels
{
	public class MainWindowViewModel : UIViewModel<MainWindow>
	{
		private readonly IRestClientProvider apiProvider;
		public MainWindowViewModel(IRestClientProvider apiClientProvider)
		{
			apiProvider = apiClientProvider;
			ReloadPriceItemsCommand = new AsyncRelayCommand<DistributorPriceListDto>(ReloadPriceListItemsAsync, item => item?.Id != null);
			ReloadProductsCommand = new AsyncRelayCommand<PriceListItem>(ReloadProductsAsync, item => item?.Id != null);
			StartAnalizeCommand = new AsyncRelayCommand<CompareRequest>(AnalizeAsync, q => q?.BasePriceId.HasValue == true);
			AnalizeQuery = new CompareRequest();
			ReloadPriceLists = new AsyncRelayCommand<DistributorDto>(UpdatePriceLists, d => d != null);
		}

		#region ICommand
		public IAsyncRelayCommand<CompareRequest> StartAnalizeCommand { get => Get<AsyncRelayCommand<CompareRequest>>(); set => Set(value); }

		public IAsyncRelayCommand<DistributorDto> ReloadPriceLists
		{
			get => Get<AsyncRelayCommand<DistributorDto>>();
			set => Set(value);
		}


		public IAsyncRelayCommand<DistributorPriceListDto> ReloadPriceItemsCommand
		{
			get => Get<AsyncRelayCommand<DistributorPriceListDto>>();
			set => Set(value);
		}
		public IAsyncRelayCommand<PriceListItem> ReloadProductsCommand
		{
			get => Get<AsyncRelayCommand<PriceListItem>>();
			set => Set(value);
		}
		#endregion

		#region Properties
		public CompareRequest AnalizeQuery { get => Get<CompareRequest>(); set => Set(value); }

		public DistributorDto SelectedDistributor
		{
			get => Get<DistributorDto>();
			set
			{
				Set(value);
				SafeStartCommand(ReloadPriceLists, value);
			}
		}

		public DistributorPriceListDto SelectedPrice
		{
			get => Get<DistributorPriceListDto>();
			set { Set(value); ReloadPriceItemsCommand.Execute(value); }
		}

		public PriceListItem SelectedPriceItem
		{
			get => Get<PriceListItem>();
			set { Set(value); SafeStartCommand(ReloadProductsCommand, value); }
		}
		#endregion

		#region Collections
		public ObservableCollection<DistributorDto> Distributors
			=> ScheduleInitLoad(LoadDistributors, Get<ObservableCollection<DistributorDto>>(initialize: true));

		public ObservableCollection<DistributorPriceListDto> PriceLists
			=> Get<ObservableCollection<DistributorPriceListDto>>(initialize: true);

		public ObservableCollection<PriceProductInfo> SelectedPriceProducts
			=> Get<ObservableCollection<PriceProductInfo>>(initialize: true);

		public ObservableCollection<PriceListItem> AllPricesProducts
			=> Get<ObservableCollection<PriceListItem>>(initialize: true);

		public IEnumerable<KeyValuePair<string, CompareKind>> CompareKinds
			=> Enum.GetValues<CompareKind>().Select(s
				=> new KeyValuePair<string, CompareKind>(Enum.GetName(s) ?? s.ToString(), s));

		#endregion

		private async Task AnalizeAsync(CompareRequest query)
		{
			var items = await apiProvider.Products.AnalizeAsync(query);
			LoadCollection(AllPricesProducts, items);
		}

		protected override async Task LoadDataAsync()
		{
			await Task.Delay(100);
		}

		async Task ReloadPriceListItemsAsync(DistributorPriceListDto price)
		{
			AllPricesProducts?.Clear();
			if (price?.Id is Guid Id)
			{
				var response = await apiProvider.PriceLists.ItemsAsync<PriceListItem>(Id);
				if (response.Content is IEnumerable<PriceListItem> items)
					LoadCollection(AllPricesProducts, items);
			}
			StartAnalizeCommand.NotifyCanExecuteChanged();
		}

		async Task ReloadProductsAsync(PriceListItem selected)
		{
			var products = await apiProvider.Products.FindAllAsync<PriceProductInfo>(selected?.Id ?? default, selected);
			LoadCollection(SelectedPriceProducts, products);
		}

		async Task UpdatePriceLists(DistributorDto distributor)
		{
			using var src = new CancellationTokenSource(TimeSpan.FromMinutes(1));
			var response = await apiProvider.Distributors.PriceListsAsync(distributor);
			if (response.Content is IEnumerable<DistributorPriceListDto> prices)
				LoadCollection<DistributorPriceListDto>(PriceLists, prices);
		}

		async void LoadDistributors(ObservableCollection<DistributorDto> collection)
		{
			using var src = new CancellationTokenSource(TimeSpan.FromMinutes(1));

			var distributors = await apiProvider.Distributors.GetAllAsync();
			LoadCollection<DistributorDto>(collection, distributors);
		}
	}
}
