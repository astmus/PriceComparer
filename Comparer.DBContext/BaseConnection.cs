
using System;
using System.Data.Common;
using System.Linq;

using Comparer.DataAccess.Config;

using LinqToDB;

using Microsoft.Extensions.Options;



namespace Comparer.Data.Context
{
	public abstract class BaseConnection : LinqToDB.Data.DataConnection
	{

		public IQueryable<TResult> FromRaw<TResult>(string raw, params object[] args)
			=> this.FromSql<TResult>(raw, args.ToArray());

		public BaseConnection(IOptions<ConnectionOptions> options = default, DataOptions dataOptions = default) : base(options.Value.DataProvider, options.Value.ConnectionString)
		{
#if DEBUG
			TurnTraceSwitchOn();
			WriteTraceLine = (message, displayName, level)
				=> System.Console.WriteLine($">> {message} {Environment.NewLine} {displayName} {Environment.NewLine} {level}");
#endif
		}

		public DbConnection InitConnection()
			=> DataProvider.CreateConnection(Options.ConnectionOptions.ConnectionString);
	}
}
