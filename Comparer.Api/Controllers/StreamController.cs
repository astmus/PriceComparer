using System.Text;
using System.Text.Unicode;

using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.Entities;

using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Microsoft.AspNetCore.Http;

namespace Comparer.Api.Controllers
{
	public class StreamController : BaseController
	{
		public StreamController(IGenericRepository repository = null) : base(repository)
		{
		}
		[HttpPost("hook")]
		public async Task<ActionResult<Stream>> GetWebHook([FromBody] Product parameter)
		{
			return Ok(await Task.FromResult(new MemoryStream(Encoding.UTF8.GetBytes(parameter.ToString()), false)));
		}
		[HttpPost]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
		[ProducesDefaultResponseType]
		public async Task<IActionResult> HandleWebHook()
		{
			//var exceptionHandlerFeature =
			//	HttpContext.Features.Get<IExceptionHandlerFeature>()!;
			if (HttpContext.Items["JSON"] is JToken ctx)
				//return Problem(
				//	detail: exceptionHandlerFeature.Error.StackTrace,
				//	title: exceptionHandlerFeature.Error.Message);
				//await HttpContext.Response.WriteAsJsonAsync(ctx);
				return Ok(ctx.ToString());
			else
				return BadRequest("Body of request does not content valid JSON");
			//return await Task.FromResult(new MemoryStream());
		}

		[Route("/error")]
		public IActionResult HandleError() =>
			Problem();
	}
}
