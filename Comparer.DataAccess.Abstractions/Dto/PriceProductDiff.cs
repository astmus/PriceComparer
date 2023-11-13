using System.Text.Json.Serialization;

namespace Comparer.DataAccess.Dto
{
	public record PriceProductDiff : PriceListProduct, IProductInfoPovider
	{
		public Guid Id { get; init; }
		public Guid? DisID { get; init; }
		public Guid? PriceListId { get; init; }
		public string? PriceListName { get; init; }
		public double? BasePrice { get; init; }
		public double? MinPrice { get; init; }
		public double? MaxPrice { get; init; }
		public string? Notes { get; init; }
	}

	public record PriceDiffDto : PriceListItem
	{
		[JsonPropertyName("min")]
		public double? MinPrice { get; init; }

		[JsonPropertyName("max")]
		public double? MaxPrice { get; init; }

		public double? BasePrice { get; init; }
	}

	public record PriceProductDiffDto : PriceDiffDto, IProductInfoPovider
	{
		public Guid Id { get; init; }

		[JsonPropertyName("list")]
		public PriceListData? PriceList { get; init; }
		public string? Notes { get; init; }
	}
}
