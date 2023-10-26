﻿#pragma warning disable 1573, 1591

using LinqToDB;

namespace Comparer.Api.DataModels
{
	public static partial class TableExtensions
	{
		public static DISTRIBUTOR Find(this ITable<DISTRIBUTOR> table, Guid ID)
		{
			return table.FirstOrDefault(t =>
				t.ID == ID);
		}

		public static LINK Find(this ITable<LINK> table, Guid ID)
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
