using System.Text.Json.Serialization;

namespace Comparer.DataAccess.Dto
{
	public record ProductUnit : DataUnit
	{
		[JsonPropertyName("child")]
		public string? ChildName { get; init; }
	}

	public record PriceProduct : ProductUnit, IProductInfoPovider
	{
		public double Price { get; init; }
	}

	public record PriceListProduct : PriceListItem, IPriceListInfoProvider
	{
		[JsonPropertyName("prod")]
		public PriceProduct Product { get; init; }

		[JsonPropertyName("list")]
		public PriceListData? PriceList { get; init; }

		public Guid? GetPriceListId()
			=> PriceList?.Id;
	}
}
