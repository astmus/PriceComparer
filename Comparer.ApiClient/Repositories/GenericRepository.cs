

using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading;
using System.Threading.Tasks;

using Comparer.DataAccess.Abstractions.Repositories;

using LinqToDB;
using LinqToDB.SqlQuery;

namespace Comparer.DataAccess.Repositories;


public abstract class GenericRepository<T> : IGenericRepository<T> where T : class
{
	protected readonly DataBaseConnection _connection;

	public GenericRepository(DataBaseConnection connection)
		=> _connection = connection;

	public IQueryable<T> Request() => _connection.GetTable<T>();
	public IEnumerable<T> GetAll() => _connection.GetTable<T>().ToList();
	public IAsyncEnumerable<T> GetAllAsync(CancellationToken cancel = default) => _connection.GetTable<T>().AsAsyncEnumerable();
	public async Task<bool> ContainItemAsync(Expression<Func<T, bool>> predicate)
	{
		return await _connection.GetTable<T>().AnyAsync(predicate);
	}
	public abstract IQueryable<TEntity> FromRaw<TEntity>();
}
