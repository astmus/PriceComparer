
namespace Comparer.DataAccess.Dto
{
	public class PriceListItem
	{
		public virtual Guid? ProductId { get; init; }
		public PriceInfo? PriceList { get; init; }
		public string? ItemName { get; init; }
		public virtual string? ProductName { get; init; }
		public double? Price { get; init; }
	}
}
