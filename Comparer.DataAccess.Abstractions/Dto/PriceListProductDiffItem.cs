namespace Comparer.DataAccess.Dto
{
	public record PriceListProductDiffItem : PriceListProduct
	{
		public PriceProductInfo Product { get; init; }


		public string PriceListName
			=> Product?.PriceList?.Name;
		public double? MinPriceDiff
			=> Price;
		public double? MaxPriceDiff
			=> Price;
		public string? Notes { get; init; }

	}
}
