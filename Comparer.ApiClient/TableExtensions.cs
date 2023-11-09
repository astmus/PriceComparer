
using System.Linq;

using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Models;
using Comparer.Entities;

using LinqToDB;

namespace Comparer.DataAccess
{
	public static partial class TableExtensions
	{
		public static DISTRIBUTOR Find(this ITable<DISTRIBUTOR> table, Guid ID)
		{
			return table.FirstOrDefault(t =>
				t.Id == ID);
		}
		public static TDist Find<TDist>(this ITable<TDist> table, Guid ID) where TDist : Distributor
		{
			return table.FirstOrDefault(t =>
				t.Id == ID);
		}

		internal static LINK Find(this ITable<LINK> table, Guid ID)
		{
			return table.FirstOrDefault(t =>
				t.ID == ID);
		}


		public static PRICESRECORD Find(this ITable<PRICESRECORD> table, int RECORDINDEX)
		{
			return table.FirstOrDefault(t =>
				t.RECORDINDEX == RECORDINDEX);
		}

		public static PRODUCT Find(this ITable<PRODUCT> table, Guid ID)
		{
			return table.FirstOrDefault(t =>
				t.ID == ID);
		}
	}
}
