using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using CommunityToolkit.Mvvm.Input;

using Comparer.DataAccess.Requests;
using Comparer.DataAccess.Rest;
using Comparer.DesktopClient.Models;
using Comparer.CollectionExtensions;

using CompareKind = Comparer.DataAccess.Dto.CompareKind;
using Distributor = Comparer.DataAccess.Dto.DistributorData;
using DistributorPriceList = Comparer.DataAccess.Dto.DistributorPriceListData;
using IPriceListInfoProvider = Comparer.DataAccess.Dto.IPriceListInfoProvider;
using IProductInfoPovider = Comparer.DataAccess.Dto.IProductInfoPovider;
using PriceListItem = Comparer.DataAccess.Dto.PriceListItem;

namespace Comparer.DesktopClient.ViewModels
{
	public class MainWindowViewModel : UIViewModel<MainWindow>
	{
		private readonly IRestClientProvider apiProvider;
		public MainWindowViewModel(IRestClientProvider apiClientProvider)
		{
			apiProvider = apiClientProvider;
			ReloadPriceItemsCommand = new AsyncRelayCommand<DistributorPriceList>(ReloadPriceListDataAsync, item => item != default);
			ReloadProductsCommand = new AsyncRelayCommand<PriceListItem>(ReloadPriceProductsAsync, item => item != default);
			StartAnalizeCommand = new AsyncRelayCommand<CompareRequest>(AnalizeAsync, q => q?.BasePriceId.HasValue == true);
			AnalizeQuery = new CompareRequest();
			ReloadPriceLists = new AsyncRelayCommand<Distributor>(UpdatePriceLists, d => d != null);
		}

		#region ICommand
		public IAsyncRelayCommand<CompareRequest> StartAnalizeCommand { get => Get<AsyncRelayCommand<CompareRequest>>(); set => Set(value); }

		public IAsyncRelayCommand<Distributor> ReloadPriceLists
		{
			get => Get<AsyncRelayCommand<Distributor>>();
			set => Set(value);
		}


		public IAsyncRelayCommand<DistributorPriceList> ReloadPriceItemsCommand
		{
			get => Get<AsyncRelayCommand<DistributorPriceList>>();
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

		public Distributor SelectedDistributor
		{
			get => Get<Distributor>();
			set
			{
				Set(value);
				SafeStartCommand(ReloadPriceLists, value);
			}
		}

		public DistributorPriceList SelectedPrice
		{
			get => Get<DistributorPriceList>();
			set { Set(value); ReloadPriceItemsCommand.Execute(value); }
		}

		public PriceListItem SelectedPriceItem
		{
			get => Get<PriceListItem>();
			set { Set(value); SafeStartCommand(ReloadProductsCommand, value); }
		}
		#endregion

		#region Collections
		public ObservableCollection<Distributor> Distributors
			=> GetOrScheduleInit<ObservableCollection<Distributor>>(LoadDistributors);

		public ObservableCollection<DistributorPriceList> PriceLists
			=> Get<ObservableCollection<DistributorPriceList>>(initialize: true);

		public ObservableCollection<PriceListProduct> SelectedPriceProducts
			=> Get<ObservableCollection<PriceListProduct>>(initialize: true);

		public ObservableCollection<PriceListItem> AllPricesProducts
			=> Get<ObservableCollection<PriceListItem>>(initialize: true);

		public IEnumerable<KeyValuePair<string, CompareKind>> CompareKinds
			=> Enum.GetValues<CompareKind>().Select(s
				=> new KeyValuePair<string, CompareKind>(Enum.GetName(s) ?? s.ToString(), s));

		#endregion

		private async Task AnalizeAsync(CompareRequest query)
		{
			var items = await apiProvider.Products.AnalizeAsync(query);

			var update = (from i in AllPricesProducts.Cast<PriceListProduct>()
						  join p in items on (i.Id, i.Price) equals (p.Id, p.BasePrice) into joined
						  from J in joined.DefaultIfEmpty()
						  select i with
						  {
							  Diff = J,
							  PriceList = J?.PriceList ?? SelectedPrice,
							  Distributor = J is not null ? Distributors.FirstOrDefault(d => d.Id == J?.PriceList?.DisID) : SelectedPrice.Distributor
						  }).Distinct().OrderBy(o => o.Id);

			LoadCollection(AllPricesProducts, update.ToList());
		}

		protected override async Task LoadDataAsync()
		{
			await Task.CompletedTask;
		}

		async Task ReloadPriceListDataAsync(DistributorPriceList price)
		{
			AllPricesProducts?.Clear();
			if (price?.Id is Guid Id)
			{
				var response = await apiProvider.PriceLists.ContentAsync<PriceListProduct>(Id);
				if (response.Content is DataAccess.Dto.PriceListDto<PriceListProduct> data)
				{
					var items = data.Items.ForEachPrepare(
							item => item.Distributor = SelectedDistributor).OrderBy(o => o.Id);
					LoadCollection(AllPricesProducts, items);
				}
			}
			StartAnalizeCommand.NotifyCanExecuteChanged();
		}

		async Task ReloadPriceProductsAsync(PriceListItem selected)
		{
			if (selected is IProductInfoPovider current)
			{
				IPriceListInfoProvider args = selected as IPriceListInfoProvider;
				var products = await apiProvider.Products.AllAsync<PriceListProduct>(current.Id, args?.GetPriceListId());
				var distributors = Distributors;
				products.ForEachPrepare(p => p.Distributor = distributors.FirstOrDefault(f => f.Id == p.PriceList.DisID));
				LoadCollection(SelectedPriceProducts, products);
			}
		}

		async Task UpdatePriceLists(Distributor distributor)
		{
			using var src = new CancellationTokenSource(TimeSpan.FromMinutes(1));
			PriceLists.Clear();

			var response = await apiProvider.Distributors.PriceListsAsync(distributor);
			if (response.Content is IEnumerable<DistributorPriceList> prices)
				LoadCollection<DistributorPriceList>(PriceLists, prices);
		}

		async void LoadDistributors(ObservableCollection<Distributor> collection)
		{
			using var src = new CancellationTokenSource(TimeSpan.FromMinutes(1));

			var distributors = await apiProvider.Distributors.GetAllAsync();
			LoadCollection<Distributor>(collection, distributors);
		}
	}
}
