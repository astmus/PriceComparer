using System.Collections.Generic;

using Comparer.Data.Context;
using Comparer.Data.Extensions;
using Comparer.DataAccess.Abstractions;

using LinqToDB;
using LinqToDB.Linq;
namespace Comparer.DataAccess.Repositories;

public class ManufacturerRepository : GenericRepository<Entities.Manufacturer>, IManufacturerRepository
{
	ComparerDataContext ctx;
	public ManufacturerRepository(ComparerDataContext connection) : base(connection)
	{
		ctx = connection;
	}

	public IExpressionQuery<Entities.Manufacturer> Manufacturers => ctx.GetTable<Entities.Manufacturer>();

	protected override string rootTableName
		=> "MANUFACTURERS";

	public IEnumerable<TM> LoadManufacturers<TM>() where TM : Entities.Manufacturer
	{
		var m = ctx.ManufacturersView<TM>(default);//.QueryProc<TM>("ManufacturersView").ToList();

		return m;
	}
}
