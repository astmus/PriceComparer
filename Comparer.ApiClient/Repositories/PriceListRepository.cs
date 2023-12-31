using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Models;
using Comparer.DBContext;

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
	public PriceListRepository(DataBaseConnection dbConnection) : base(dbConnection)
		=> connection = dbConnection;

	DataBaseConnection connection;


	public IExpressionQuery<PRICE> PriceLists => connection.PRICES;
	protected override string rootTableName
		=> nameof(connection.PRICES);

	public async Task<PriceListDto> ContentAsync(Guid priceListId, CancellationToken cancel = default)
	{
		if (await RawQuery<PriceListData>().FirstOrDefaultAsync(f => f.Id == priceListId, cancel) is not PriceListData info) return default;

		var result = new PriceListDto<PriceListProduct>()
		{
			Info = info,
			Items = await
				(
				from rec in connection.PRICESRECORDS
				join link in connection.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
				join prod in MapTo<PriceProduct>(connection.PRODUCTS) on link.CATALOGPRODUCTID equals prod.Id
				join dist in connection.DISTRIBUTORS on info.DisID equals dist.Id
				where rec.PRICEID == priceListId
				select new PriceListProduct()
				{
					PriceList = info,
					Product = prod,
					Price = rec.PRICE
				})
			.ToListAsync(cancel)
		};
		return result;
	}

	public async Task<IEnumerable<PriceListItem>> ItemsAsync(Guid priceListId, CancellationToken cancel = default)
	{
		var reference = await RawQuery<PriceListData>().FirstOrDefaultAsync(f => f.Id == priceListId, cancel);
		if (reference == null) return Enumerable.Empty<PriceListItem>();

		var resultQuery =
				from rec in connection.PRICESRECORDS
				join link in connection.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
				join prod in MapTo<ProductUnit>(connection.PRODUCTS) on link.CATALOGPRODUCTID equals prod.Id
				where rec.PRICEID == priceListId
				select new PriceListItemDto()
				{
					PriceList = reference,
					Price = rec.PRICE
				};

		// need more complicated query for grouping prices
		var result = await resultQuery.ToListAsync(cancel);
		return result;
	}
}
