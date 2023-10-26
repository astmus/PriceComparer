namespace Comparer.Api.Config
{
	public record ConnectionOptions
	{
		public const string ContextOptions = nameof(ConnectionOptions);
		public string ConnectionString { get; set; } = string.Empty;
		public string DataProvider { get; set; } = string.Empty;
	}
}
