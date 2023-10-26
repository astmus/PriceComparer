namespace Comparer.DataAccess.Dto
{
	public record ProductInfo : PriceListItem
	{
		public ProductInfo() : base()
		{
		}

		public double? PriceDiff { get; init; }
		public string? DistributorName { get; init; }
	}
}
