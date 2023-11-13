using System;
using System.Text.Json.Serialization;

using Comparer.DataAccess.Dto;

namespace Comparer.DesktopClient.Models
{
	public record PriceListProduct : PriceListItem, IProductInfoPovider, IPriceListInfoProvider
	{
		public Guid Id => Product.Id;

		[JsonPropertyName("prod")]
		public PriceProduct Product { get; init; }

		[JsonPropertyName("list")]
		public PriceListData? PriceList { get; init; }

		internal DistributorData? Distributor { get; set; }
		internal PriceProductDiffDto? Diff { get; set; }

		public override string? Name
			=> Product.Name + " " + Product.ChildName;

		public string PriceListName
			=> PriceList?.Name;

		public string DistributorName
			=> Distributor?.Name;

		public double? MinPrice => Diff is null ? null : Diff?.MinPrice ?? 0;
		public double? MaxPrice => Diff is null ? null : Diff?.MaxPrice ?? 0;

		public Guid? GetPriceListId()
			=> PriceList?.Id;
	}
}
