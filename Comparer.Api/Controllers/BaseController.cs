//using MediatR;

using System.Net;

using Comparer.Api.Errors;

using Microsoft.AspNetCore.Mvc;


namespace Comparer.Api.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	[Produces("application/json")]
	public class BaseController : ControllerBase
	{
		//protected IMediator Mediator => mediator ??= HttpContext.RequestServices.GetService<IMediator>();
		protected void ThrowClient(int code, string message, string description = null)
		{
			throw new ApiException(message)
			{
				Result = BadRequest()
			};
		}

		protected CancellationTokenSource OperationCancelling
#if DEBUG
		=> new CancellationTokenSource();
#else
			=> new CancellationTokenSource(2500);
#endif
	}
}
