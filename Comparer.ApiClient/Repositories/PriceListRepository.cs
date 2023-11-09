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

public interface IPriceListRepository : IGenericRepository<PRICE>
{
	IExpressionQuery<PRICE> PriceLists { get; }
	Task<IEnumerable<PriceListItem>> ItemsAsync(Guid priceListId, CancellationToken cancel = default);
	Task<PriceListDto> ContentAsync(Guid priceListId, CancellationToken cancel = default);
}

public class PriceListRepository : GenericRepository<PRICE>, IPriceListRepository
{
	public PriceListRepository(DataBaseConnection connection) : base(connection) { }

	public IExpressionQuery<PRICE> PriceLists => db.PRICES;
	protected override string rootTableName
		=> nameof(db.PRICES);

	public async Task<PriceListDto> ContentAsync(Guid priceListId, CancellationToken cancel = default)
	{
		if (await RawQuery<PriceListInfo>().FirstOrDefaultAsync(f => f.Id == priceListId, cancel) is not PriceListInfo info) return default;

		var result = new PriceListDto()
		{
			Info = info,
			Items = await
				(
				from listItem in db.PRICESRECORDS
				join link in db.LINKS on listItem.RECORDINDEX equals link.PRICERECORDINDEX
				join prod in MapTo<ProductInfo>(db.PRODUCTS) on link.CATALOGPRODUCTID equals prod.Id
				join dist in db.DISTRIBUTORS on info.DisID equals dist.Id
				where listItem.PRICEID == priceListId
				select new PriceListProduct()
				{
					Id = prod.Id,
					Product = prod,
					PriceList = info,
					Price = listItem.PRICE
				})//.GroupBy(g=>g.Product).ForEachAsync(a => a.GroupBy(sm=>sm, sm=> sm.Price).)
				 .ToListAsync(cancel)
		};
		return result;
	}

	public async Task<IEnumerable<PriceListItem>> ItemsAsync(Guid priceListId, CancellationToken cancel = default)
	{
		var reference = await RawQuery<PriceListInfo>().FirstOrDefaultAsync(f => f.Id == priceListId, cancel);
		if (reference == null) return null;

		var resultQuery =
				from rec in db.PRICESRECORDS
				join link in db.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
				join prod in MapTo<ProductInfo>(db.PRODUCTS) on link.CATALOGPRODUCTID equals prod.Id
				where rec.PRICEID == priceListId
				select new PriceListItem()
				{
					//Product = prod,
					PriceList = reference,
					Price = rec.PRICE
				};
		// need more complicated query for grouping prices
		var result = await resultQuery.ToListAsync(cancel);
		return result;
	}
}
