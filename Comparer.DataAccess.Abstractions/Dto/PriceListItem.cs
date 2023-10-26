
namespace Comparer.DataAccess.Dto
{
	public record PriceListItem
	{
		public Guid? ProductId { get; init; }
		public GuidObject? PriceList { get; init; }
		public string? ItemName { get; init; }
		public string? ProductName { get; init; }
		//public string? DistributorName { get; init; }
		public double? Price { get; init; }
	}
}
