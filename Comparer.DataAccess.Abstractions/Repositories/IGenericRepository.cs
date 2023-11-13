using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading;
using System.Threading.Tasks;

namespace Comparer.DataAccess.Abstractions.Repositories;

public interface IGenericRepository<T> : IGenericRepository where T : class
{
	Task<bool> ItemExistAsync(Expression<Func<T, bool>> predicate, CancellationToken cancel = default);
	IQueryable<T> Query();
	IEnumerable<T> GetAll();
	Task<IEnumerable<T>> GetAllAsync(CancellationToken cancel = default);
}

