using System;

namespace Comparer.Dto
{
	public record PriceList(Guid ID, string? NAME, Guid? DISID = default)
	{
	}
}
