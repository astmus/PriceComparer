using System.Collections.Generic;

using Comparer.Data.Context;
using Comparer.DataAccess.Abstractions;
using Comparer.Entities;

using LinqToDB;
using LinqToDB.Linq;
namespace Comparer.DataAccess.Repositories;

public class ManufacturerRepository : GenericRepository<Manufacturer>, IManufacturerRepository
{
	ComparerDataContext ctx;
	public ManufacturerRepository(ComparerDataContext connection) : base(connection)
	{
		ctx = connection;
	}

	public IExpressionQuery<Manufacturer> Manufacturers => ctx.GetTable<Manufacturer>();

	protected override string rootTableName
		=> "MANUFACTURERS";

	public IEnumerable<TM> LoadManufacturers<TM>() where TM : Manufacturer
		=> ctx.ManufacturersView(default);//.QueryProc<TM>("ManufacturersView").ToList();
}
