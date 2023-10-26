using System.Linq;

namespace Comparer.DataAccess.Abstractions.Repositories
{
	public interface IRepository
	{
		IQueryable<TEntity> FromRaw<TEntity>(string raw);
	}
}