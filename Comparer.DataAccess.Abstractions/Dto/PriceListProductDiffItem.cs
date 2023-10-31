namespace Comparer.DataAccess.Dto
{
	public class ProductDiffItem : PriceListItem
	{
		public double MinPrice { get; init; }
		public double MaxPrice { get; init; }
	}
	public class PriceListProductDiffItem : ProductDiffItem
	{
		public PriceProductInfo Product { get; init; }
		public override Guid? ProductId
			=> Product?.Id;
		public double PriceDiff
			=> Math.Round(Price - Product?.Price ?? 0, 3);
		public override string? ProductName { get => Product.ProductName; }
		public string DistributorName
			=> Product.DistributorName;
		public string PriceListName
			=> Product?.PriceList?.NAME;
		public double? MaxPriceDiff { get; init; }
		public string? Notes { get; init; }

	}
}
