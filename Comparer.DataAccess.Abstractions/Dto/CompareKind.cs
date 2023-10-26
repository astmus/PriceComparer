using System.ComponentModel;

namespace Comparer.DataAccess.Dto
{
	public enum CompareKind : byte
	{
		[Description("Compare all")]
		All,
		[Description("Compare by minimal price")]
		MinPrice,
		[Description("Compare by minimal price other distributors")]
		OtherMinPrice
	}
}
