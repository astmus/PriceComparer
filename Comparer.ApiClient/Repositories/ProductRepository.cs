using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Models;

using LinqToDB;
using LinqToDB.Linq;

namespace Comparer.DataAccess.Repositories;

public interface IProductRepository : IGenericRepository<PRODUCT>
{
	IExpressionQuery<PRODUCT> Products { get; }
	IAsyncEnumerable<ProductInfo> List(Guid productId);
}

public class ProductRepository : GenericRepository<PRODUCT>, IProductRepository
{
	public ProductRepository(DataBaseConnection connection) : base(connection)
	{
	}

	public IExpressionQuery<PRODUCT> Products => _connection.PRODUCTS;

	public Task<IEnumerable<PRODUCT>> Content(Guid ProductId, CancellationToken cancel = default) => throw new NotImplementedException();
	public override IQueryable<TEntity> FromRaw<TEntity>() => _connection.FromRaw<TEntity>(nameof(_connection.PRODUCTS));

	public IAsyncEnumerable<ProductInfo> List(Guid productId)
	{
		return (
				from rec in _connection.PRICESRECORDS
				join link in _connection.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
				join prod in _connection.PRODUCTS on link.CATALOGPRODUCTID equals prod.ID
				where rec.PRICEID == productId
				select new ProductInfo()
				{
					ProductId = prod.ID,
					ItemName = rec.NAME,
					ProductName = $"{prod.NAME} {prod.CHILDNAME}",
					Price = rec.PRICE
				}
					).AsAsyncEnumerable();
	}
}
