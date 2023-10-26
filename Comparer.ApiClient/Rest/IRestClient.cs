using System.Collections.Generic;
using System.Threading.Tasks;

namespace Comparer.DataAccess.Rest
{
	public interface IRestClient<TPoint> where TPoint : class
	{
		[GetApi]
		Task<IEnumerable<TGet>> GetAsync<TGet>() where TGet : TPoint;
		[GetApi("{id}")]
		Task<TPoint> GetByKeyAsync<TKey>(TKey id);
		//[Get("/api/")]
		//IAsyncEnumerable<TGet> GetStream<TGet>() where TGet : TPoint;
	}
}
