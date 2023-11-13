using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Comparer.DataAccess.Abstractions.Repositories
{
	public interface IRepository
	{
		IQueryable<TEntity> FromRaw<TEntity>(string raw, params object[] args);
	}

	public interface IGenericRepository
	{
		IQueryable<TResult> RawQuery<TResult>(string rawQuery = null, params object[] args);
		Task<TEntity[]> RawQueryAsync<TEntity>(string rawQuery, CancellationToken cancel = default) where TEntity : class;
	}
}