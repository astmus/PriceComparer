using System.Text.Json.Serialization;

namespace Comparer.DataAccess.Dto
{

	public record DistributorInfo(Guid? Id, string? Name)
	{
	}

	public record Distributor(Guid Id, string? Name = default, bool? Active = default) : GuidObject(Id)
	{

	}
}
