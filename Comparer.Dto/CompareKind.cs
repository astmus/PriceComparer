using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace Comparer.Dto
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
