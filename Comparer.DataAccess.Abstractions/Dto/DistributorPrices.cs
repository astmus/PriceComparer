using System.Collections.Generic;
using System.Linq;

namespace Comparer.DataAccess.Dto
{
	public record DistributorPrices(Guid DistributorId, string DistributorName)
	{
		public IEnumerable<DistributorPriceDto> PriceLists = Enumerable.Empty<DistributorPriceDto>();
	}
}
