using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;

using Comparer.ApiClient;
using Comparer.ApiClient.Queries;
using Comparer.ApiClient.Rest;
using Comparer.DesktopClient.Commands;
using Comparer.Dto;

namespace Comparer.DesktopClient.ViewModels
{
	public class MainWindowViewModel : ViewModel<MainWindow>
	{
		private readonly IRestClientProvider apiProvider;
		public MainWindowViewModel(IRestClientProvider apiClientProvider)
		{
			apiProvider = apiClientProvider;
		}

		#region ICommand
		public ICommand StartAnalizeCommand
		=> new AsyncCommand<CompareQuery>(AnalizeAsync, query => query.BasePriceId.HasValue, error => MessageBox.Show(error.Message));
		public ICommand ReloadProductsCommand
			=> new AsyncCommand<PriceListItem>(ReloadProductsAsync, item => item != null, error => MessageBox.Show(error.Message));
		public override ICommand LoadMainDataCommand
			=> new AsyncCommand(LoadDataAsync, onException: error => MessageBox.Show(error.Message));
		#endregion

		public Distributor SelectedDistributor
		{
			get => Get<Distributor>();
			set => Set(value).IIF(value, LoadPriceLists, ReloadPriceLists);
		}

		public PriceList SelectdPrice
		{
			get => Get<PriceList>();
			set => Set(value).IIF(value, ReloadProductsCommand.Execute);
		}

		public IList<Distributor> Distributors
			=> ScheduleExecute<ObservableCollection<Distributor>>(LoadDictributors, Get);
		public IList<PriceList> PriceLists
			=> ScheduleExecute<Distributor, ObservableCollection<PriceList>>(LoadPriceLists, SelectedDistributor, Get);
		public IEnumerable<KeyValuePair<string, CompareKind>> CompareKinds
			=> Enum.GetValues<CompareKind>().Select(s
				=> new KeyValuePair<string, CompareKind>(Enum.GetName(s) ?? s.ToString(), s));

		private async Task AnalizeAsync(CompareQuery query)
		{
			throw new Exception("Exception");
			await Task.Delay(100);
		}

		protected override async Task LoadDataAsync()
		{
			await Task.Delay(100);

		}

		async Task ReloadProductsAsync(PriceListItem selected)
		{
			if (selected.ItemId is Guid id)
			{
				var products = await ComparerApi.Rest.ClientProvider.PriceLists.ProductsAsync(id);
				//PriceListProducts.Reload(products.OrderBy(p => p.Price));
			}
			//else
			//PriceListProducts.Clear();
		}

		void ReloadPriceLists(Distributor selected)
		{
			PriceLists?.Clear();
			LoadPriceLists(selected);
		}
		async void LoadPriceLists(Distributor selected)
		{
			if (selected == null) return;
			using var src = new CancellationTokenSource(TimeSpan.FromMinutes(1));
			var response = await apiProvider.Distributors.PriceLists(selected.Id);
			await LoadCollection<PriceList>(Get<ObservableCollection<PriceList>>(name: nameof(PriceLists)), response.Content);
		}

		async Task LoadCollection<TItem>(ObservableCollection<TItem> dest, IAsyncEnumerable<TItem> source)
		{
			using var src = new CancellationTokenSource(TimeSpan.FromMinutes(1));
			await foreach (var dist in source.WithCancellation(src.Token))
				if (!IsMainThread)
					Application.Current.Dispatcher.Invoke(dest.Add, dist);
				else
					dest.Add(dist);
		}

		async void LoadDictributors(ObservableCollection<Distributor> dest)
		{
			using var src = new CancellationTokenSource(TimeSpan.FromMinutes(1));
			var response = await apiProvider.Distributors.GetAllStream();
			await LoadCollection<Distributor>(dest, response.Content);
		}
	}

	file static class Ext
	{
		public static void IIF<T>(this bool value, T arg, Action<T> runTrue, Action<T> runFalse = default)
		{
			var action = value switch
			{
				false when arg is null => runTrue,
				true when arg is not null => runFalse,
				_ => default
			};
			action?.Invoke(arg);
		}
	}
}
