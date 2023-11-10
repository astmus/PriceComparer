using System.Collections;
using System.Collections.Generic;

namespace Comparer.DataAccess.Dto
{
	public class PriceListDto
	{
		public PriceListData Info { get; init; }
		public IEnumerable Items { get; init; }
	}
	public class PriceListDto<TListItem> : PriceListDto where TListItem : PriceListItem
	{
		public new IEnumerable<TListItem> Items { get; init; }
	}
}
