//using MediatR;

using System.Net;
using System.Net.Mime;

using Comparer.Api.Errors;
using Comparer.Api.Filters;
using Comparer.DataAccess.Abstractions.Repositories;
using Comparer.DataAccess.Dto;

using LinqToDB;

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Infrastructure;

namespace Comparer.Api.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	[Produces(MediaTypeNames.Application.Json)]
	public class BaseController : ControllerBase
	{
		private readonly IGenericRepository _repository;

		//protected IMediator Mediator => mediator ??= HttpContext.RequestServices.GetService<IMediator>();

		public BaseController(IGenericRepository repository)
		{
			_repository = repository;
		}

		[HttpGet]
		[SerializationFilter]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status204NoContent)]
		public async Task<ActionResult<IEnumerable<DataUnit>>> Get()
		{
			using var cancel = OperationCancelling;

			var items = await _repository.RawQuery<DataUnit>().ToListAsync(cancel.Token);
			if (items.Count == 0)
			{
				LogWarning("Repository does not contain basic items of type" + _repository.GetType().Name);
				return NoContent();
			}

			LogInfo($"Items count: {items.Count}");
			return Ok(items);
		}

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
		protected void LogWarning(string? message)
			=> log.LogWarning(message);
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
