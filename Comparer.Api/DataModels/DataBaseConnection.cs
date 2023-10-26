#pragma warning disable 1573, 1591

using System.Data.Common;

using Comparer.Api.Config;

using LinqToDB;

using Microsoft.Extensions.Options;

namespace Comparer.Api.DataModels
{
	public partial class DataBaseContext : DataContext
	{
		public ITable<DISTRIBUTOR> DISTRIBUTORS { get { return this.GetTable<DISTRIBUTOR>(); } }
		public ITable<LINK> LINKS { get { return this.GetTable<LINK>(); } }
		public ITable<PRICE> PRICES { get { return this.GetTable<PRICE>(); } }
		public ITable<PRICESRECORD> PRICESRECORDS { get { return this.GetTable<PRICESRECORD>(); } }
		public ITable<PRODUCT> PRODUCTS { get { return this.GetTable<PRODUCT>(); } }

		public DataBaseContext(IOptions<ConnectionOptions> options, DataOptions dataOptions = default) : base(options.Value.DataProvider, options.Value.ConnectionString)
		{
#if DEBUG
			LinqToDB.Data.DataConnection.TurnTraceSwitchOn();
			LinqToDB.Data.DataConnection.WriteTraceLine = (message, displayName, level)
				=> Console.WriteLine($">> {message} {displayName} {Environment.NewLine}");
#endif
		}

		public DbConnection InitConnection()
			=> DataProvider.CreateConnection(Options.ConnectionOptions.ConnectionString);
	}
}
