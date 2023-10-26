using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Comparer.DataAccess.Abstractions.Repositories
{
	public interface IGenericRepository
	{

		Task<IEnumerable<TResult>> RawAsync<TResult>(string request, CancellationToken cancel = default, params KeyValuePair<object, object>[] parameters) where TResult : class;

		//Task<TResult> HandleScalarAsync<TResult>(IUnitRequest cmd, CancellationToken cancel = default) where TResult : class, IContentUnit;
		//Task<IMetaArray> HandleQueryAsync(IUnitRequest request, CancellationToken cancel = default);
	}
	public interface IJsonRepository : IGenericRepository
	{
		Task<IEnumerable<TUnit>> HandleJsonQueryAsync<TUnit>(string query, CancellationToken cancel = default) where TUnit : class;
	}

	public interface IJsonRepository<TJsonUnit> : IGenericRepository where TJsonUnit : class
	{

	}


}
