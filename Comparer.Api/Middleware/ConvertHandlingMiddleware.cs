using Comparer.Api.Errors;

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Comparer.Api.Middleware
{
	public class ConvertHandlingMiddleware
	{
		private readonly RequestDelegate _next;
		protected ILogger _logger;

		public ConvertHandlingMiddleware(RequestDelegate next, ILogger<ConvertHandlingMiddleware> logger)
		{
			_logger = logger;
			_next = next;
		}

		public async Task Invoke(HttpContext httpContext)
		{
			try
			{
				using var textReader = new StreamReader(httpContext.Request.Body);

				using var reader = new JsonTextReader(textReader);
				JsonSerializer serializer = new JsonSerializer();
				httpContext.Items.Add("JSON", serializer.Deserialize<JObject>(reader));
				await _next(httpContext);
			}
			catch (JsonReaderException error)
			{
				httpContext.Response.StatusCode = StatusCodes.Status400BadRequest;
				await httpContext.Response.WriteAsync(error.Message);
			}
			catch (Exception ex)
			{
				_logger.LogError(ex, "unhandled exception");
				httpContext.Response.StatusCode = StatusCodes.Status500InternalServerError;
			}
		}
	}


	public static class ConvertErrorMiddlewareExtensions
	{
		public static IApplicationBuilder UseConvertHandlingMiddleware(this IApplicationBuilder builder)
		{
			return builder.UseMiddleware<ConvertHandlingMiddleware>();
		}
	}
}
