//using MediatR;

using System.Net;
using System.Net.Mime;

using Comparer.Api.Errors;

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Infrastructure;

namespace Comparer.Api.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	[Produces(MediaTypeNames.Application.Json)]
	public class BaseController : ControllerBase
	{
		//protected IMediator Mediator => mediator ??= HttpContext.RequestServices.GetService<IMediator>();
		protected void ThrowClient(int code, string message, string description = null)
		{
			LogError($"Code: {code}, message: {message}, description:{description}");
			throw new ApiException(message)
			{
				Result = new StatusCodeResult(code)
			};
		}

		#region Log
		protected virtual ILogger log
			=> GetLogger<BaseController>();
		protected ILogger<TController> GetLogger<TController>() where TController : BaseController
			=> HttpContext.RequestServices.GetService<ILogger<TController>>();
		protected void LogInfo(string? message)
			=> log.LogInformation(message);
		protected void LogError(string? message)
		=> log.LogError(message);
		protected void Log(string? message)
			=> log.Log(LogLevel.None, message);
		#endregion

		protected CancellationTokenSource OperationCancelling
#if DEBUG
		=> new CancellationTokenSource();
#else
			=> new CancellationTokenSource(2500);
#endif
	}
}
