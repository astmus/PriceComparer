namespace Comparer.DataAccess.Dto
{
	public class ProductDiffItem : PriceListItem
	{
		public double? MinPrice { get; init; }
		public double? MaxPrice { get; init; }
	}

	public class PriceListProductDiffItem : ProductDiffItem
	{
		public PriceProductInfo Product { get; init; }
		public override Guid? ProductId
			=> Product?.Id;
		public double? PriceDiff
			=> Price - Product?.Price;
		public override string? ProductName
			=> Product?.ProductName;
		public string DistributorName
			=> Product.DistributorName;
		public string PriceListName
			=> Product?.PriceList?.NAME;
		public double? MinPriceDiff
			=> MinPrice.HasValue ? MinPrice - Price : default;
		public double? MaxPriceDiff
			=> MaxPrice.HasValue ? MaxPrice - Price : default;
		public string? Notes { get; init; }

	}
}
