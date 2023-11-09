

using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading;
using System.Threading.Tasks;

using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Dto;

using LinqToDB;

namespace Comparer.DataAccess.Repositories;


public abstract class GenericRepository<T> : IGenericRepository<T> where T : class
{
	protected readonly DataBaseConnection db;
	protected abstract string rootTableName { get; }

	public IQueryable<T> Query() => db.GetTable<T>();
	public IEnumerable<T> GetAll() => db.GetTable<T>().ToList();
	public async Task<IEnumerable<T>> GetAllAsync(CancellationToken cancel = default) => await db.GetTable<T>().ToListAsync(cancel);
	public async Task<bool> ItemExistAsync(Expression<Func<T, bool>> predicate)
	{
		return await db.GetTable<T>().AnyAsync(predicate);
	}
	public IQueryable<TResult> RawQuery<TResult>(string rawQuery = null, params object[] args)
		=> db.FromSql<TResult>(rawQuery ?? rootTableName, args.ToArray());

	protected IQueryable<TEntity> MapTo<TEntity>(ITable<object> table) where TEntity : BaseUnit
		=> RawQuery<TEntity>(table.TableName);

	public IQueryable<TEntity> MapToBy<TEntity>(TEntity entity) where TEntity : BaseUnit
		=> db.FromSql<TEntity>(rootTableName).Where(w => w == entity);


	public GenericRepository(DataBaseConnection connection)
		=> this.db = connection;
}
