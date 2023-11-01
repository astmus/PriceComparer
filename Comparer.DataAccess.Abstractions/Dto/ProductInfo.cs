namespace Comparer.DataAccess.Dto
{
	public class ProductInfo
	{
		public Guid? Id { get; init; }
		public string? Name { get; init; }
		public double Price { get; init; }
	}

	public class PriceProductInfo : ProductInfo
	{
		public Guid PriceListId { get; init; }
		public PriceInfo? PriceList { get; init; }
		public string? ProductName { get; init; }
		public string? DistributorName { get; init; }
		public double? PriceDiff { get; init; }
	}
}
