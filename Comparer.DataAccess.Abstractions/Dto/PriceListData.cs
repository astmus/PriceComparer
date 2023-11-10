
namespace Comparer.DataAccess.Dto
{
	public record PriceListData : DataUnit
	{
		public Guid? DisID { get; init; }
		public bool? IsActive { get; init; }
	}
}
