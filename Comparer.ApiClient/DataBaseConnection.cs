#pragma warning disable 1573, 1591

using System.Data.Common;
using System.Linq;

using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Config;
using Comparer.DataAccess.Models;

using LinqToDB;

using Microsoft.Extensions.Options;

namespace Comparer.DataAccess
{
	public class DataBaseConnection : LinqToDB.Data.DataConnection, IRepository
	{
		public ITable<DISTRIBUTOR> DISTRIBUTORS => this.GetTable<DISTRIBUTOR>();
		public ITable<LINK> LINKS => this.GetTable<LINK>();
		public ITable<PRICE> PRICES => this.GetTable<PRICE>();
		public ITable<PRICESRECORD> PRICESRECORDS => this.GetTable<PRICESRECORD>();
		public ITable<PRODUCT> PRODUCTS => this.GetTable<PRODUCT>();
		public IQueryable<TEntity> FromRaw<TEntity>(string raw)
			=> this.FromSql<TEntity>(raw);
		public IQueryable<Dto.ProductInfo> PriceListProducts =>
				from prod in PRODUCTS
				join link in LINKS on prod.ID equals link.CATALOGPRODUCTID
				join rec in PRICESRECORDS on link.PRICERECORDINDEX equals rec.RECORDINDEX
				join list in PRICES on rec.PRICEID equals list.ID
				join dist in DISTRIBUTORS on list.DISID equals dist.ID
				select new Dto.ProductInfo()
				{
					//PriceListId = list,
					ProductId = prod.ID,
					ItemName = list.NAME,
					ProductName = rec.NAME,
					DistributorName = dist.NAME,
					Price = rec.PRICE
				};

		public DataBaseConnection(IOptions<ConnectionOptions> options, DataOptions dataOptions = default) : base(options.Value.DataProvider, options.Value.ConnectionString)
		{
#if DEBUG
			TurnTraceSwitchOn();
			WriteTraceLine = (message, displayName, level)
				=> Console.WriteLine($">> {message} {Environment.NewLine} {displayName} {Environment.NewLine} {level}");
#endif
		}

		public DbConnection InitConnection()
			=> DataProvider.CreateConnection(Options.ConnectionOptions.ConnectionString);
	}
}
