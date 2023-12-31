namespace Comparer.DataAccess.Config
{
	public record ConnectionOptions
	{
		public const string ContextOptions = nameof(ConnectionOptions);
		public string ConnectionString { get; set; } = string.Empty;
		public string DataProvider { get; set; } = "SqlServer.2022";
	}
}
