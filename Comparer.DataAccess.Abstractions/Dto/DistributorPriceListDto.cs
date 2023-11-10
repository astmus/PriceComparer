namespace Comparer.DataAccess.Dto
{
	public class DistributorPriceListDto
	{
		public PriceListData PriceList { get; init; }
		public DistributorData Distributor { get; init; }
	}
	public record DistributorPriceListData : PriceListData
	{
		public DistributorPriceListData()
		{
		}
		public DistributorPriceListData(PriceListData data) : base(data)
		{
		}
		public DistributorData Distributor { get; init; }
	}
}
