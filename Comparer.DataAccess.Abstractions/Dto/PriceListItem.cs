
using Comparer.DataAccess.Abstractions.Common;

namespace Comparer.DataAccess.Dto
{
	public record ListItem : DataUnit
	{
		public virtual DataUnit? ParentList { get; init; }
	}
	public record PriceListItem : ListItem
	{
		public PriceListInfo? PriceList { get; init; }
		public double? Price { get; init; }
	}

	public record PriceListProduct : PriceListItem
	{
		public override Guid Id => Product.Id;
		public ProductInfo? Product { get; init; }
		public double[]? Prices { get; init; }
	}
}
