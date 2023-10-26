using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading;
using System.Threading.Tasks;

namespace Comparer.DataAccess.Abstractions.Repositories;

public interface IGenericRepository<T> where T : class
{
	Task<bool> ContainItemAsync(Expression<Func<T, bool>> predicate);
	IQueryable<T> Request();
	IEnumerable<T> GetAll();
	IAsyncEnumerable<T> GetAllAsync(CancellationToken cancel = default);
	IQueryable<TEntity> FromRaw<TEntity>();
}



