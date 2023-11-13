using System.Collections.Generic;
using System.Threading.Tasks;

using Comparer.DataAccess.Dto;

using Refit;

namespace Comparer.DataAccess.Rest
{
	public interface IRestClient
	{
		[Get("/{id}")]
		Task<IEnumerable<DataUnit>> AllAsync([AliasAs("id")] Guid Id);
	}
}
