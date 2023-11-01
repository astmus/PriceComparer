
using System.Text.Json.Serialization;

using Comparer.Api.Middleware;
using Comparer.DataAccess;
using Comparer.DataAccess.Config;

namespace Comparer.Api
{
	public class Program
	{
		public static void Main(string[] args)
		{
			var builder = WebApplication.CreateBuilder(args);

			builder.Services.AddControllers()
									.AddJsonOptions(options =>
									{
										options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
										options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.Preserve;
										options.JsonSerializerOptions.IgnoreReadOnlyProperties = true;
									});

			builder.Services.AddEndpointsApiExplorer();
			builder.Services.AddSwaggerGen();
			builder.Services.AddDataBaseRepositories();

			builder.Services.AddOptions<ConnectionOptions>().Bind(builder.Configuration.GetSection(nameof(ConnectionOptions)));

			var app = builder.Build();

			if (app.Environment.IsDevelopment())
			{
				app.UseSwagger();
				app.UseSwaggerUI();
				app.UseExceptionHandler("/error-dev");
				app.UseErrorHandlingMiddleware();
			}
			else
			{
				app.UseExceptionHandler("/error");
			}

			//app.UseHttpsRedirection();

			//app.UseAuthorization();


			app.MapControllers();

			app.Run();
		}
	}
}