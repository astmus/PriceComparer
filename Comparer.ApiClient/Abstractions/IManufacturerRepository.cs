using System.Collections.Generic;

using Comparer.DataAccess.Abstractions.Repositories;

using LinqToDB.Linq;

namespace Comparer.DataAccess.Abstractions;

public interface IManufacturerRepository : IGenericRepository<Entities.Manufacturer>
{
	IExpressionQuery<Entities.Manufacturer> Manufacturers { get; }
	IEnumerable<TM> LoadManufacturers<TM>() where TM : Entities.Manufacturer;
}
