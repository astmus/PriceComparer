using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace Comparer.Api.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[ApiExplorerSettings(IgnoreApi = true)]
	[ProducesErrorResponseType(typeof(NotFoundResult))]
	public class ErrorsController : ControllerBase
	{
		[Route("/error-dev")]
		public IActionResult HandleErrorDevelopment([FromServices] IHostEnvironment hostEnvironment)
		{
			if (!hostEnvironment.IsDevelopment())
			{
				return NotFound();
			}

			var exceptionHandlerFeature =
				HttpContext.Features.Get<IExceptionHandlerFeature>()!;

			return Problem(
				detail: exceptionHandlerFeature.Error.StackTrace,
				title: exceptionHandlerFeature.Error.Message);
		}

		[Route("/error")]
		public IActionResult HandleError() =>
			Problem();
	}
}
