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
	Task<IEnumerable<PriceProductInfo>> GetPriceProductsAsync(Guid productId, ProductInfo info, CancellationToken cancel = default);
}

public class ProductRepository : GenericRepository<PRODUCT>, IProductRepository
{
	public ProductRepository(DataBaseConnection connection) : base(connection)
	{
	}

	public IExpressionQuery<PRODUCT> Products => _connection.PRODUCTS;

	public Task<IEnumerable<PRODUCT>> Content(Guid ProductId, CancellationToken cancel = default) => throw new NotImplementedException();
	public override IQueryable<TEntity> FromRaw<TEntity>(string rawSql = null)
	{
		return _connection.FromSql<TEntity>(nameof(_connection.PRODUCTS));
		//using var cmd = _connection.CreateCommand();
		//cmd.CommandText = query + " " + rawSql;
		//if (cmd.ExecuteReader() is var read)
		//{
		//	var t = read.GetString(0);
		//	var doc = JsonDocument.Parse(t);
		//}
	}

	public async Task<IEnumerable<PriceProductInfo>> GetPriceProductsAsync(Guid productId, ProductInfo info, CancellationToken cancel = default)
	{
		return await (
				from rec in _connection.PRICESRECORDS
				join link in _connection.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
				join prod in _connection.PRODUCTS on link.CATALOGPRODUCTID equals prod.ID
				join list in _connection.PRICES on rec.PRICEID equals list.ID
				join dist in _connection.DISTRIBUTORS on list.DISID equals dist.ID
				where prod.ID == productId
				select new PriceProductInfo()
				{
					Id = prod.ID,
					Name = rec.NAME,
					DistributorName = dist.NAME,
					PriceList = new PriceInfo(list.ID, list.NAME, list.DISID, list.ISACTIVE),
					Price = rec.PRICE,
					PriceDiff = Math.Round(rec.PRICE - info.Price ?? 0, 3)
				}
					).OrderBy(ob => ob.Price).ToListAsync(cancel);
	}

	public async Task<IEnumerable<PriceProductInfo>> GetPriceProductsAsync(Guid productId, Guid priceId, CancellationToken cancel = default)
	{
		return await (
				from rec in _connection.PRICESRECORDS
				join link in _connection.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
				join prod in _connection.PRODUCTS on link.CATALOGPRODUCTID equals prod.ID
				where rec.PRICEID == priceId
				select new PriceProductInfo()
				{
					Id = prod.ID,
					Name = rec.NAME,
					ProductName = $"{prod.NAME} {prod.CHILDNAME}",
					Price = rec.PRICE
				}
					).ToListAsync(cancel);
	}
}
