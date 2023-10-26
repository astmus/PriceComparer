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
	Task<IEnumerable<DistributorPriceDto>> PriceListsOf(Guid id, DistributorInfo distributor);
}

public class DistributorRepository : GenericRepository<DISTRIBUTOR>, IDistributorRepository
{
	public DistributorRepository(DataBaseConnection connection) : base(connection)
	{
	}

	public IExpressionQuery<DISTRIBUTOR> Distributors => _connection.DISTRIBUTORS;

	public Task<IEnumerable<DISTRIBUTOR>> Content(Guid DistributorId, CancellationToken cancel = default) => throw new NotImplementedException();
	public override IQueryable<TEntity> FromRaw<TEntity>() => _connection.FromRaw<TEntity>(nameof(_connection.DISTRIBUTORS));
	public async Task<IEnumerable<DistributorPriceDto>> PriceListsOf(Guid id, DistributorInfo info)
	{

		var query = from list in _connection.PRICES
					where list.DISID == id
					select new DistributorPriceDto()
					{
						Id = list.ID,
						Name = list.NAME,
						IsActive = list.ISACTIVE,
						Distributor = info
					};
		var items = await query.ToListAsync();
		return items;
	}
}
