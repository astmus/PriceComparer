namespace Comparer.DataAccess.Dto
{
	public record PriceListProductDiffItem : PriceListItem
	{
		public PriceListProduct Product { get; init; }

		public string? Notes { get; init; }

	}
}
