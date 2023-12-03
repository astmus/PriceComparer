using System.Collections.Generic;
using System.Linq;

using Comparer.DataAccess.Abstractions;
using Comparer.DataAccess.Models;
using Comparer.Entities;

using LinqToDB;
using LinqToDB.Data;
using LinqToDB.Linq;

namespace Comparer.DataAccess.Repositories;

public class ManufacturerRepository : GenericRepository<MANUFACTURER>, IManufacturerRepository
{
	Data.ComparerDataContext ctx;
	public ManufacturerRepository(Data.ComparerDataContext connection) : base(connection)
	{
		ctx = connection;
	}

	public IExpressionQuery<MANUFACTURER> Manufacturers => ctx.GetTable<MANUFACTURER>();

	protected override string rootTableName
		=> "MANUFACTURERS";

	public IEnumerable<TM> LoadManufacturers<TM>() where TM : Manufacturer
		=> ctx.QueryProc<TM>().ToList();
}
