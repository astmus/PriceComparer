using Comparer.DataAccess.Dto;

namespace Comparer.DataAccess.Abstractions.Common
{
	public record PriceListInfo(Guid Id, string? Name, Guid? DisID = default, bool? IsActive = default) : BaseUnit
	{
	}
}
