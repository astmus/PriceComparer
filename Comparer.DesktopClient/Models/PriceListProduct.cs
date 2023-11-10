using Comparer.DataAccess.Dto;

namespace Comparer.DesktopClient.Models
{
	public record PriceListProduct : PriceListItem, IProductInfo
	{
		public PriceProduct Product { get; init; }
		public PriceListData? PriceList { get; init; }
		public DistributorData? Distributor { get; set; }
		public override string? Name
			=> Product.Name + " " + Product.ChildName;
		public string PriceListName
			=> PriceList?.Name;
		public string DistributorName
			=> Distributor?.Name;
	}
}
