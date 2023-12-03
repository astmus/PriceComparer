using System;
using System.Collections.Generic;
using System.Text;

using Comparer.Data.Context;

using LinqToDB.Data;

namespace Comparer.Data.Extensions
{
	public static partial class ComparerDataContextStoredProcedures
	{

		#region ManufacturersView

		public static IEnumerable<TM> ManufacturersView<TM>(this ComparerDataContext dataConnection, Guid? @Id) where TM : Entities.Manufacturer
		{
			var parameters = new[]
			{
				new DataParameter("@Id", @Id, LinqToDB.DataType.Guid)
			};

			return dataConnection.QueryProc<TM>("[dbo].[ManufacturersView]", parameters);
		}

		#endregion

	}
}
