using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using CommunityToolkit.Mvvm.Input;

using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Queries;
using Comparer.DataAccess.Rest;

namespace Comparer.DesktopClient.ViewModels
{
	public class MainWindowViewModel : UIViewModel<MainWindow>
	{
		private readonly IRestClientProvider apiProvider;
		public MainWindowViewModel(IRestClientProvider apiClientProvider)
		{
			apiProvider = apiClientProvider;
			ReloadPriceItemsCommand = new AsyncRelayCommand<DistributorPriceDto>(ReloadPriceListItemsAsync, item => item?.Id != null);
			ReloadProductsCommand = new AsyncRelayCommand<PriceListItem>(ReloadProductsAsync, item => item?.ProductId != null);
			StartAnalizeCommand = new AsyncRelayCommand<CompareQuery>(AnalizeAsync, q => q?.BasePriceId.HasValue == true);
			AnalizeQuery = new CompareQuery();
			ReloadPriceLists = new AsyncRelayCommand<DistributorInfo>(UpdatePriceLists, d => d != null);
		}

		#region ICommand
		public IAsyncRelayCommand<CompareQuery> StartAnalizeCommand { get => Get<AsyncRelayCommand<CompareQuery>>(); set => Set(value); }

		public IAsyncRelayCommand<DistributorInfo> ReloadPriceLists
		{
			get => Get<AsyncRelayCommand<DistributorInfo>>();
			set => Set(value);
		}


		public IAsyncRelayCommand<DistributorPriceDto> ReloadPriceItemsCommand
		{
			get => Get<AsyncRelayCommand<DistributorPriceDto>>();
			set => Set(value);
		}
		public IAsyncRelayCommand<PriceListItem> ReloadProductsCommand
		{
			get => Get<AsyncRelayCommand<PriceListItem>>();
			set => Set(value);
		}
		#endregion

		#region Properties
		public CompareQuery AnalizeQuery { get => Get<CompareQuery>(); set => Set(value); }

		public DistributorInfo SelectedDistributor
		{
			get => Get<DistributorInfo>();
			set
			{
				Set(value);
				SafeStartCommand(ReloadPriceLists, value);
			}
		}

		public DistributorPriceDto SelectedPrice
		{
			get => Get<DistributorPriceDto>();
			set { Set(value); ReloadPriceItemsCommand.Execute(value); }
		}

		public PriceListItem SelectedPriceItem
		{
			get => Get<PriceListItem>();
			set { Set(value); SafeStartCommand(ReloadProductsCommand, value); }
		}
		#endregion

		#region Collections
		public ObservableCollection<DistributorInfo> Distributors
			=> ScheduleInitLoad(LoadDistributors, Get<ObservableCollection<DistributorInfo>>(initialize: true));

		public ObservableCollection<DistributorPriceDto> PriceLists
			=> Get<ObservableCollection<DistributorPriceDto>>(initialize: true);

		public ObservableCollection<PriceProductInfo> SelectedPriceProducts
			=> Get<ObservableCollection<PriceProductInfo>>(initialize: true);

		public ObservableCollection<PriceListItem> AllPricesProducts
			=> Get<ObservableCollection<PriceListItem>>(initialize: true);

		public IEnumerable<KeyValuePair<string, CompareKind>> CompareKinds
			=> Enum.GetValues<CompareKind>().Select(s
				=> new KeyValuePair<string, CompareKind>(Enum.GetName(s) ?? s.ToString(), s));

		#endregion

		private Task AnalizeAsync(CompareQuery query)
		{
			return Task.FromException(new Exception("Exception"));
		}

		protected override async Task LoadDataAsync()
		{
			await Task.Delay(100);
		}

		async Task ReloadPriceListItemsAsync(DistributorPriceDto price)
		{
			AllPricesProducts?.Clear();
			if (price?.Id is Guid Id)
			{
				var response = await apiProvider.PriceLists.ItemsAsync(Id);
				if (response.Content is IEnumerable<PriceListItem> items)
					LoadCollection(AllPricesProducts, items);
			}
			StartAnalizeCommand.NotifyCanExecuteChanged();
		}

		async Task ReloadProductsAsync(PriceListItem selected)
		{
			var products = await apiProvider.Products.FindAllAsync<PriceProductInfo>(selected.ProductId ?? default, selected);
			LoadCollection(SelectedPriceProducts, products);
		}

		async Task UpdatePriceLists(DistributorInfo distributor)
		{
			using var src = new CancellationTokenSource(TimeSpan.FromMinutes(1));
			var response = await apiProvider.Distributors.PriceListsOf(distributor);
			if (response.Content is IEnumerable<DistributorPriceDto> prices)
				LoadCollection<DistributorPriceDto>(PriceLists, prices);
		}

		async void LoadDistributors(ObservableCollection<DistributorInfo> collection)
		{
			using var src = new CancellationTokenSource(TimeSpan.FromMinutes(1));
			var i3 = await apiProvider.PriceLists.GetAllAsync();
			var i2 = await apiProvider.PriceLists.ContentAsync(new Guid("7e8fbf1f-82d9-43cc-bc6b-7a3b43b93814"));
			var i = await apiProvider.PriceLists.ItemsAsync(new Guid("7e8fbf1f-82d9-43cc-bc6b-7a3b43b93814"));

			var distributors = await apiProvider.Distributors.GetAllAsync();
			//if (response.Content is IEnumerable<DistributorInfo> distributors)
			LoadCollection<DistributorInfo>(collection, distributors);
		}
	}
}
