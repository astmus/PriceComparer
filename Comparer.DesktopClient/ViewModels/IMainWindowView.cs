using System.Collections.Generic;

using Comparer.DesktopClient.Models;

using CompareKind = Comparer.DataAccess.Dto.CompareKind;
using Distributor = Comparer.DataAccess.Dto.DistributorData;
using DistributorPriceList = Comparer.DataAccess.Dto.DistributorPriceListData;
using PriceListItem = Comparer.DataAccess.Dto.PriceListItem;

namespace Comparer.DesktopClient.ViewModels
{
	public interface IMainWindowView
	{
		IList<PriceListItem> AllPricesProducts { get; }
		IList<Distributor> Distributors { get; }
		IList<DistributorPriceList> PriceLists { get; }
		IList<PriceListProduct> SelectedPriceProducts { get; }
		
		IEnumerable<KeyValuePair<string, CompareKind>> CompareKinds { get; }

		Distributor SelectedDistributor { get; set; }
		DistributorPriceList SelectedPrice { get; set; }
		PriceListItem SelectedPriceItem { get; set; }
	}
}
