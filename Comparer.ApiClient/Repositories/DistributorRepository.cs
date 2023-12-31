using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Models;
using Comparer.DBContext;

using LinqToDB;
using LinqToDB.Linq;

namespace Comparer.DataAccess.Repositories;

public interface IDistributorRepository : IGenericRepository<DISTRIBUTOR>
{
	IExpressionQuery<DISTRIBUTOR> Distributors { get; }
	Task<IEnumerable<DistributorPriceListData>> PriceListsAsync(DistributorData distributor, CancellationToken cancel = default);
}

public class DistributorRepository : GenericRepository<DISTRIBUTOR>, IDistributorRepository
{
	DataBaseConnection db;
	public DistributorRepository(DataBaseConnection connection) : base(connection)
		=> db = connection;

	public IExpressionQuery<DISTRIBUTOR> Distributors => db.DISTRIBUTORS;

	protected override string rootTableName
		=> nameof(db.DISTRIBUTORS);

	public async Task<IEnumerable<DistributorPriceListData>> PriceListsAsync(DistributorData distributor, CancellationToken cancel = default)
	{
		var query = from list in MapTo<PriceListData>(db.PRICES)
					where list.DisID == distributor.Id
					select new DistributorPriceListData(list)
					{
						Distributor = distributor
					};

		var items = await query.ToListAsync(cancel);
		return items;
	}
}
