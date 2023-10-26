using System.Collections;
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

public interface IPriceListRepository : IGenericRepository<PRICE>
{
	IExpressionQuery<PRICE> PriceLists { get; }
	IAsyncEnumerable<PriceListItem> Items(Guid priceListId);
	Task<PriceListDto> WithContentAsync(Guid priceListId);
}

public class PriceListRepository : GenericRepository<PRICE>, IPriceListRepository
{
	public PriceListRepository(DataBaseConnection connection) : base(connection)
	{
	}

	public IExpressionQuery<PRICE> PriceLists => _connection.PRICES;

	public async Task<PriceListDto> WithContentAsync(Guid priceListId)
	{
		var info = await FromRaw<PriceInfo>().FirstOrDefaultAsync(p => p.Id == priceListId);

		if (info is null)
			return null;

		var result = new PriceListDto(info)
		{
			Items = await
				(
				from listItem in _connection.PRICESRECORDS
				join link in _connection.LINKS on listItem.RECORDINDEX equals link.PRICERECORDINDEX
				join prod in _connection.PRODUCTS on link.CATALOGPRODUCTID equals prod.ID
				join dist in _connection.DISTRIBUTORS on info.DISID equals dist.ID
				where listItem.PRICEID == priceListId
				select new PriceListItem()
				{
					ProductId = prod.ID,
					PriceList = info,
					ItemName = listItem.NAME,
					ProductName = prod.NAME,
					//DistributorName = dist.NAME,
					Price = listItem.PRICE

				})
				 .ToListAsync()
		};
		return result;
	}


	public IAsyncEnumerable<PriceListItem> Items(Guid priceListId)
	{
		var reference = new GuidObject(priceListId);
		return (
				from rec in _connection.PRICESRECORDS
				join link in _connection.LINKS on rec.RECORDINDEX equals link.PRICERECORDINDEX
				join prod in _connection.PRODUCTS on link.CATALOGPRODUCTID equals prod.ID

				where rec.PRICEID == priceListId
				select new PriceListItem()
				{
					ProductId = prod.ID,
					PriceList = reference,
					ItemName = rec.NAME,
					ProductName = $"{prod.NAME} {prod.CHILDNAME}",
					Price = rec.PRICE
				}
			).AsAsyncEnumerable();
	}

	public override IQueryable<TEntity> FromRaw<TEntity>() => _connection.FromRaw<TEntity>(nameof(_connection.PRICES));
}
