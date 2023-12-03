using System.Collections;
using System.Collections.Generic;

using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Models;
using Comparer.Entities;

using LinqToDB.Linq;

namespace Comparer.DataAccess.Abstractions;

public interface IManufacturerRepository : IGenericRepository<MANUFACTURER>
{
	IExpressionQuery<MANUFACTURER> Manufacturers { get; }
	IEnumerable<TM> LoadManufacturers<TM>() where TM : Manufacturer;
}
