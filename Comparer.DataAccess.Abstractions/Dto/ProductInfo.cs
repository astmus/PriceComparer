using Comparer.DataAccess.Abstractions.Common;

namespace Comparer.DataAccess.Dto
{
	public record ProductInfo : DataUnit
	{
		public string? ChildName { get; init; }
	}

	public record PriceProductInfo : ProductInfo
	{
		public double?[] Prices { get; set; }
		public PriceListInfo? PriceList { get; init; }
		public string? ProductName { get; init; }
	}
}
