using System.Collections.Generic;

namespace Comparer.DataAccess.Dto
{
	public record PriceInfo(Guid Id, string? NAME, Guid? DISID = default, bool? IsActive = default) : GuidObject(Id)
	{
	}

	public class PriceListDto
	{
		public GuidObject Info { get; init; }
		public IEnumerable<PriceListItem> Items { get; init; }
	}
}
