namespace Comparer.DataAccess.Dto
{
	public class DistributorPriceListDto
	{
		public Guid Id { get; init; }
		public string Name { get; init; }
		public bool? IsActive { get; init; }
		public DistributorInfo Distributor { get; init; }
	}
}
