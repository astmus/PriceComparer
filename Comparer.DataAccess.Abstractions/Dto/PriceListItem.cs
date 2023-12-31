﻿using System.Text.Json.Serialization;

using Comparer.Entities;

namespace Comparer.DataAccess.Dto
{
	public record PriceListItem : DataUnit<PriceList>
	{
		public bool? Used { get; init; }
		public double Price { get; init; }
		public bool? Deleted { get; init; }
	}

	public record PriceListItemDto : PriceListItem
	{
		[JsonPropertyName("list")]
		public PriceListData? PriceList { get; init; }
	}
}
