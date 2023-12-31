

using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading;
using System.Threading.Tasks;

using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Dto;

using LinqToDB;
using LinqToDB.Data;

namespace Comparer.DataAccess.Repositories;


public abstract class GenericRepository<T> : IGenericRepository<T> where T : class
{
	readonly LinqToDB.Data.DataConnection connection;
	protected abstract string rootTableName { get; }

	public IQueryable<T> Query() => connection.GetTable<T>();
	public IEnumerable<T> GetAll() => connection.GetTable<T>().ToList();
	public async Task<IEnumerable<T>> GetAllAsync(CancellationToken cancel = default)
		=> await connection.GetTable<T>().ToListAsync(cancel);

	public async Task<bool> ItemExistAsync(Expression<Func<T, bool>> predicate, CancellationToken cancel = default)
		=> await connection.GetTable<T>().AnyAsync(predicate, cancel);

	public IQueryable<TResult> RawQuery<TResult>(string rawQuery = null, params object[] args)
		=> connection.FromSql<TResult>(rawQuery ?? rootTableName, args.ToArray());

	public Task<TEntity[]> RawQueryAsync<TEntity>(string query, CancellationToken cancel = default) where TEntity : class
		=> connection.QueryToArrayAsync<TEntity>(query, cancel);

	protected IQueryable<TEntity> MapTo<TEntity>(ITable<object> table) where TEntity : BaseUnit
		=> connection.FromSql<TEntity>(table.TableName);

	protected IQueryable<TEntity> MapToBy<TEntity>(TEntity entity) where TEntity : BaseUnit
		=> connection.FromSql<TEntity>(rootTableName).Where(w => w == entity);

	public GenericRepository(LinqToDB.Data.DataConnection connection)
		=> this.connection = connection;
}
