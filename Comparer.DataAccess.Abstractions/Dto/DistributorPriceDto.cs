using System.Text.Json.Serialization;

namespace Comparer.DataAccess.Dto
{
	public class DistributorPriceDto
	{
		public Guid Id { get; init; }
		public string Name { get; init; }
		public bool? IsActive { get; init; }
		public DistributorInfo Distributor { get; init; }
		//public DistributorPriceDto(DistributorInfo? info, Guid? id, string name, bool? isActive = default)
		//{

		//}
	}
}
