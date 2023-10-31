using Comparer.DataAccess.Dto;

namespace Comparer.DataAccess.Requests
{
	public class CompareRequest
	{
		public Guid? BasePriceId { get; set; }
		public CompareKind Kind { get; set; }
	}
}
