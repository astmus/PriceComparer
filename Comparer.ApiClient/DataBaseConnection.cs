﻿
using System.Data.Common;
using System.Linq;

using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Config;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Models;

using LinqToDB;
using LinqToDB.SqlQuery;

using Microsoft.Extensions.Options;

namespace Comparer.DBContext
{
	public class DataBaseConnection : LinqToDB.Data.DataConnection, IRepository
	{
		public ITable<DISTRIBUTOR> DISTRIBUTORS => this.GetTable<DISTRIBUTOR>();
		public ITable<PRICE> PRICES => this.GetTable<PRICE>();
		public ITable<PRICESRECORD> PRICESRECORDS => this.GetTable<PRICESRECORD>();
		public ITable<PRODUCT> PRODUCTS => this.GetTable<PRODUCT>();
		internal ITable<LINK> LINKS => this.GetTable<LINK>();

		public IQueryable<TResult> FromRaw<TResult>(string raw, params object[] args)
			=> this.FromSql<TResult>(raw, args.ToArray());

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
