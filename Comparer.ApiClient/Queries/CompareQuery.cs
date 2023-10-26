using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Text;

using Comparer.Dto;

namespace Comparer.ApiClient.Queries
{
	public class CompareQuery
	{
		public Guid? BasePriceId { get; set; }
		public CompareKind Kind { get; set; }
	}
}
