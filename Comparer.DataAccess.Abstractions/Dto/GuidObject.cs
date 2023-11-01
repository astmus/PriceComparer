using System.Text.Json.Serialization;

namespace Comparer.DataAccess.Dto
{
	public record IdentibleInfo(Guid Name, object Value);
	public record GuidObject(Guid Id = default);
}
