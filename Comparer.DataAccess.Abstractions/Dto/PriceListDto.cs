using System.Collections.Generic;

namespace Comparer.DataAccess.Dto
{
	public record PriceInfo(Guid Id, string? NAME, Guid? DISID = default, bool? IsActive = default) : GuidObject(Id)
	{
	}

	public record PriceListDto(GuidObject Info)
	{
		public IEnumerable<PriceListItem> Items { get; init; }
	}
}
