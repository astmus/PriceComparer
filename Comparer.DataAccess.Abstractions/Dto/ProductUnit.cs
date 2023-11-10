namespace Comparer.DataAccess.Dto
{
	public record ProductUnit : DataUnit
	{
		public string? ChildName { get; init; }
	}

	public interface IProductInfo
	{
		double Price { get; init; }
	}

	public record PriceProduct : ProductUnit, IProductInfo
	{
		public double Price { get; init; }
	}

	public record PriceListProduct : PriceListItem
	{
		public PriceProduct Product { get; init; }
		public PriceListData? PriceList { get; init; }
	}
}
