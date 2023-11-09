using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Models;

using LinqToDB;
using LinqToDB.Linq;

namespace Comparer.DataAccess.Repositories;

public interface IDistributorRepository : IGenericRepository<DISTRIBUTOR>
{
	IExpressionQuery<DISTRIBUTOR> Distributors { get; }
	Task<IEnumerable<DistributorPriceListDto>> PriceListsAsync(DistributorInfo distributor, CancellationToken cancel = default);
}

public class DistributorRepository : GenericRepository<DISTRIBUTOR>, IDistributorRepository
{
	public DistributorRepository(DataBaseConnection connection) : base(connection)
	{
	}

	public IExpressionQuery<DISTRIBUTOR> Distributors => db.DISTRIBUTORS;

	protected override string rootTableName
		=> nameof(db.DISTRIBUTORS);

	public async Task<IEnumerable<DistributorPriceListDto>> PriceListsAsync(DistributorInfo distributor, CancellationToken cancel = default)
	{
		var query = from list in db.PRICES
					where list.DISID == distributor.Id
					select new DistributorPriceListDto()
					{
						Id = list.ID,
						Name = list.NAME,
						IsActive = list.ISACTIVE,
						Distributor = distributor
					};
		var items = await query.ToListAsync(cancel);
		return items;
	}
}
