
using System.Text.Json.Serialization;

using Comparer.Api.Middleware;
using Comparer.DataAccess;
using Comparer.DataAccess.Config;
using Comparer.DataAccess.Dto;

using Microsoft.AspNetCore.Server.Kestrel.Core;

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
										options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingDefault;
										options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.Preserve;
										options.JsonSerializerOptions.IgnoreReadOnlyFields = true;
									});

			builder.Services.AddEndpointsApiExplorer();
			builder.Services.AddSwaggerGen();
			builder.Services.AddDataBaseRepositories();

			builder.Services.AddOptions<ConnectionOptions>().Bind(builder.Configuration.GetSection(nameof(ConnectionOptions)));
			builder.Services.Configure<KestrelServerOptions>(options =>
			{
				options.AllowSynchronousIO = true;
			});
			//builder.Services.Configure<RouteOptions>(o => o.ConstraintMap.Add("uid", typeof(Id)));
			var app = builder.Build();

			if (app.Environment.IsDevelopment())
			{
				app.UseSwagger();
				app.UseSwaggerUI();
				app.UseExceptionHandler("/error-dev");
				app.UseErrorHandlingMiddleware();
				app.UseConvertHandlingMiddleware();
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