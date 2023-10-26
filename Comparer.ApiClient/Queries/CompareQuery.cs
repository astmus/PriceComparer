using Comparer.DataAccess.Dto;

namespace Comparer.DataAccess.Queries
{
	public class CompareQuery
	{
		public Guid? BasePriceId { get; set; }
		public CompareKind Kind { get; set; }
	}
}
