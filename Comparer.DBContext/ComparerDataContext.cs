

using Comparer.DataAccess.Config;

using Microsoft.Extensions.Options;

namespace Comparer.Data.Context
{
	public partial class ComparerDataContext
	{

		public ComparerDataContext(IOptions<ConnectionOptions> options, LinqToDB.DataOptions dataOptions = default) : base(options, dataOptions)
		{ }

	}
}
