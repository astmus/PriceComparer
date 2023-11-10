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
	Task<IEnumerable<ProductUnit>> ProductsAsync(Guid productId, ProductUnit info, CancellationToken cancel = default);
	Task<IEnumerable<PriceProduct>> PriceProductsAsync(Guid productId, CancellationToken cancel = default);
	IQueryable<PriceListProduct> PriceListProducts { get; }
	IQueryable<PriceListProduct> AvailablePriceListProducts { get; }
}

public class ProductRepository : GenericRepository<PRODUCT>, IProductRepository
{
	public ProductRepository(DataBaseConnection connection) : base(connection) { }
	protected override string rootTableName
		=> nameof(db.PRODUCTS);

	public IExpressionQuery<PRODUCT> Products => db.PRODUCTS;


	public IQueryable<PriceListProduct> PriceListProducts
		=> from prod in db.PRODUCTS
		   join link in db.LINKS on prod.Id equals link.CATALOGPRODUCTID
		   join rec in db.PRICESRECORDS on link.PRICERECORDINDEX equals rec.RECORDINDEX
		   join list in MapTo<PriceListData>(db.PRICES) on rec.PRICEID equals list.Id
		   join dist in db.DISTRIBUTORS on list.DisID equals dist.Id
		   select new PriceListProduct()
		   {
			   Product = new PriceProduct()
			   {
				   Id = prod.Id,
				   Name = prod.NAME,
				   ChildName = prod.CHILDNAME,
				   Price = prod.PRICE * 12345
			   },
			   PriceList = list,
			   Name = rec.NAME,
			   Price = rec.PRICE
		   };

	public IQueryable<PriceListProduct> AvailablePriceListProducts
		=> from prod in db.PRODUCTS
		   join link in db.LINKS on prod.Id equals link.CATALOGPRODUCTID
		   join rec in db.PRICESRECORDS on link.PRICERECORDINDEX equals rec.RECORDINDEX
		   join list in MapTo<PriceListData>(db.PRICES) on rec.PRICEID equals list.Id
		   join dist in db.DISTRIBUTORS on list.DisID equals dist.Id
		   where dist.ACTIVE && list.IsActive == true && !rec.DELETED && rec.USED
		   select new PriceListProduct()
		   {
			   Product = new PriceProduct()
			   {
				   Id = prod.Id,
				   Name = prod.NAME,
				   ChildName = prod.CHILDNAME,
				   Price = rec.PRICE
			   },
			   PriceList = list,
			   Name = rec.NAME
		   };

	public async Task<IEnumerable<ProductUnit>> ProductsAsync(Guid productId, ProductUnit info, CancellationToken cancel = default)
	{
		return await (
				from rec in db.PRICESRECORDS
				join link in db.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
				join prod in db.PRODUCTS on link.CATALOGPRODUCTID equals prod.Id
				join list in MapTo<PriceListData>(db.PRICES) on rec.PRICEID equals list.Id
				join dist in db.DISTRIBUTORS on list.DisID equals dist.Id
				where prod.Id == productId
				select new ProductUnit()
				{
					Id = prod.Id,
					Name = prod.NAME,
					ChildName = prod.CHILDNAME
				}
			).ToListAsync(cancel);
	}

	public async Task<IEnumerable<PriceProduct>> PriceProductsAsync(Guid priceId, CancellationToken cancel = default)
	{
		return await (
				from rec in db.PRICESRECORDS
				join link in db.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
				join prod in db.PRODUCTS on link.CATALOGPRODUCTID equals prod.Id
				where rec.PRICEID == priceId
				select new PriceProduct()
				{
					Id = prod.Id,
					Name = prod.NAME,
					ChildName = prod.CHILDNAME,
					Price = rec.PRICE
				}
		).OrderBy(ob => ob.Price).ToListAsync(cancel);
	}
}
