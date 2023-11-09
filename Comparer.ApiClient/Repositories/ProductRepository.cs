using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using Comparer.DataAccess.Abstractions.Common;
using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Models;

using LinqToDB;
using LinqToDB.Linq;

namespace Comparer.DataAccess.Repositories;

public interface IProductRepository : IGenericRepository<PRODUCT>
{
	IExpressionQuery<PRODUCT> Products { get; }
	Task<IEnumerable<PriceProductInfo>> GetProductsAsync(Guid productId, ProductInfo info, CancellationToken cancel = default);
	Task<IEnumerable<PriceProductInfo>> GetPriceProductsAsync(Guid priceId, CancellationToken cancel = default);
	IQueryable<PriceProductInfo> PriceListProducts { get; }
	IQueryable<PriceProductInfo> AvailablePriceListProducts { get; }
}

public class ProductRepository : GenericRepository<PRODUCT>, IProductRepository
{
	public ProductRepository(DataBaseConnection connection) : base(connection) { }
	protected override string rootTableName
		=> nameof(db.PRODUCTS);

	public IExpressionQuery<PRODUCT> Products => db.PRODUCTS;

	public IQueryable<PriceProductInfo> PriceListProducts =>
				from prod in db.PRODUCTS
				join link in db.LINKS on prod.ID equals link.CATALOGPRODUCTID
				join rec in db.PRICESRECORDS on link.PRICERECORDINDEX equals rec.RECORDINDEX
				join list in MapTo<PriceListInfo>(db.PRICES) on rec.PRICEID equals list.Id
				join dist in db.DISTRIBUTORS on list.DisID equals dist.Id
				select new PriceProductInfo()
				{
					PriceList = list,
					Id = prod.ID,
					ProductName = $"{prod.NAME} {prod.CHILDNAME}"//,
																 //Prices = { rec.PRICE }
				};
	public IQueryable<PriceProductInfo> AvailablePriceListProducts =>
				from prod in db.PRODUCTS
				join link in db.LINKS on prod.ID equals link.CATALOGPRODUCTID
				join rec in db.PRICESRECORDS on link.PRICERECORDINDEX equals rec.RECORDINDEX
				join list in MapTo<PriceListInfo>(db.PRICES) on rec.PRICEID equals list.Id
				join dist in db.DISTRIBUTORS on list.DisID equals dist.Id
				where dist.ACTIVE && list.IsActive == true && !rec.DELETED && rec.USED
				select new PriceProductInfo()
				{
					Id = prod.ID,
					PriceList = list,
					Name = rec.NAME,
					ProductName = $"{prod.NAME} {prod.CHILDNAME}"
					//Prices = rec.PRICE
				};

	public async Task<IEnumerable<PriceProductInfo>> GetProductsAsync(Guid productId, ProductInfo info, CancellationToken cancel = default)
	{
		return await (
				from rec in db.PRICESRECORDS
				join link in db.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
				join prod in db.PRODUCTS on link.CATALOGPRODUCTID equals prod.ID
				join list in MapTo<PriceListInfo>(db.PRICES) on rec.PRICEID equals list.Id
				join dist in db.DISTRIBUTORS on list.DisID equals dist.Id
				where prod.ID == productId
				select new PriceProductInfo()
				{
					Id = prod.ID,
					Name = rec.NAME,
					PriceList = list//,
									//Prices = rec.PRICE,
				}
					).OrderBy(ob => ob.Prices).ToListAsync(cancel);
	}

	public async Task<IEnumerable<PriceProductInfo>> GetPriceProductsAsync(Guid priceId, CancellationToken cancel = default)
	{
		return await (
				from rec in db.PRICESRECORDS
				join link in db.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
				join prod in db.PRODUCTS on link.CATALOGPRODUCTID equals prod.ID
				where rec.PRICEID == priceId
				select new PriceProductInfo()
				{
					Id = prod.ID,
					Name = rec.NAME,
					ProductName = $"{prod.NAME} {prod.CHILDNAME}"
					//Prices = rec.PRICE
				}
		).ToListAsync(cancel);
	}
}
