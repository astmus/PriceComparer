using Comparer.Api.Errors;

namespace Comparer.Api.Middleware
{
	public class ErrorHandlingMiddleware
	{
		private readonly RequestDelegate _next;
		protected ILogger _logger;

		public ErrorHandlingMiddleware(RequestDelegate next, ILogger<ErrorHandlingMiddleware> logger)
		{
			_logger = logger;
			_next = next;
		}

		public async Task Invoke(HttpContext httpContext)
		{
			try
			{
				await _next(httpContext);
			}
			catch (ApiException error)
			{
				httpContext.Response.StatusCode = error.Result.StatusCode;
				await httpContext.Response.WriteAsync(error.Message);
			}
			catch (Exception ex)
			{
				_logger.LogError(ex, "unhandled exception");

				await WriteStatus500InternalServerError(httpContext);
			}
		}

		private async Task WriteStatus500InternalServerError(HttpContext httpContext)
		{
			httpContext.Response.StatusCode = StatusCodes.Status500InternalServerError;
			await _next(httpContext);
		}
	}


	public static class HandleErrorMiddlewareExtensions
	{
		public static IApplicationBuilder UseErrorHandlingMiddleware(this IApplicationBuilder builder)
		{
			return builder.UseMiddleware<ErrorHandlingMiddleware>();
		}
	}
}
