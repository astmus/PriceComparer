using System;

namespace Comparer.Dto
{
	public class PriceListItem
	{
		public Guid? ItemId { get; init; }
		public string? ItemName { get; init; }
		public string? ProductName { get; init; }
		public double? Price { get; init; }
	}
}
