using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using Comparer.DataAccess.Abstractions;
using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Models;
using Comparer.Entities;

using LinqToDB;
using LinqToDB.Linq;

namespace Comparer.DataAccess.Repositories;

public class ManufacturerRepository : GenericRepository<MANUFACTURER>, IManufacturerRepository
{
	public ManufacturerRepository(DataBaseConnection connection) : base(connection)
	{
	}

	public IExpressionQuery<MANUFACTURER> Manufacturers => db.GetTable<MANUFACTURER>();

	protected override string rootTableName
		=> "MANUFACTURERS";
}
