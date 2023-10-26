using System;

namespace Comparer.Dto
{
	public class PriceListProduct : PriceListItem
	{
		public Guid? ProductId { get; init; }
		//public string? ProductName { get; init; }
		public string? DistributorName { get; init; }
	}
}
