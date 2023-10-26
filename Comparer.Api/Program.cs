using Comparer.Api.Config;
using Comparer.Api.DataModels;

using LinqToDB.AspNet;
using LinqToDB.AspNet.Logging;

namespace Comparer.Api
{
	public class Program
	{
		public static void Main(string[] args)
		{
			var builder = WebApplication.CreateBuilder(args);

			builder.Services.AddControllers();
			builder.Services.AddEndpointsApiExplorer();
			builder.Services.AddSwaggerGen();
			builder.Services.AddLinqToDBContext<DataBaseContext>((provider, options)
				=> options
					.UseDefaultLogging(provider));

			builder.Services.AddOptions<ConnectionOptions>().Bind(builder.Configuration.GetSection(nameof(ConnectionOptions)));
			var app = builder.Build();


			if (app.Environment.IsDevelopment())
			{
				app.UseSwagger();
				app.UseSwaggerUI();
				app.UseExceptionHandler("/error-dev");
			}
			else
			{
				app.UseExceptionHandler("/error");
			}

			app.UseHttpsRedirection();

			app.UseAuthorization();


			app.MapControllers();

			app.Run();
		}
	}
}