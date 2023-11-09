using System.Collections.Generic;

using Comparer.DataAccess.Abstractions.Common;


namespace Comparer.DataAccess.Dto
{

	public class PriceListDto
	{
		public PriceListInfo Info { get; init; }
		public IEnumerable<PriceListItem> Items { get; init; }
	}
}
