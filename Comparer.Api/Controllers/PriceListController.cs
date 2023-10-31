using System.Text.Json;

using Comparer.Api.Filters;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Repositories;

using LinqToDB;

using Microsoft.AspNetCore.Mvc;

namespace Comparer.Api.Controllers
{

	public class PriceListController : BaseController
	{
		private readonly ILogger<PriceListController> _logger;
		IPriceListRepository _repository;
		public PriceListController(ILogger<PriceListController> logger, IPriceListRepository repositroy)
		{
			_logger = logger;
			_repository = repositroy;
		}

		[HttpGet]
		[ProducesResponseType(StatusCodes.Status200OK)]
		public async Task<IEnumerable<ItemInfo<Guid>>> Get()
		{
			var items = await _repository.Request().Select(p => new ItemInfo<Guid>(p.ID, p.NAME)).ToListAsync();
			return items;
		}

		[HttpGet("{id}")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(PriceInfo))]
		[ProducesResponseType(StatusCodes.Status400BadRequest)]
		public async Task<IActionResult> Get([FromRoute(Name = "id")] Guid priceListId)
		{
			if (await _repository.FromRaw<PriceInfo>().FirstOrDefaultAsync(list => list.Id == priceListId) is PriceInfo info)
				return Ok(info);
			else
			{
				_logger.LogError($"Price list with id {priceListId} does not exist");
				return BadRequest("Wrong price list id");
			}
		}

		[HttpGet("{id}/[action]")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IAsyncEnumerable<PriceListItem>))]
		[ProducesResponseType(StatusCodes.Status400BadRequest)]
		public async Task<IEnumerable<PriceListItem>> Items([FromRoute(Name = "id")] Guid priceListId)
		{
			if (!await _repository.ContainItemAsync(list => list.ID == priceListId))
				ThrowClient(StatusCodes.Status400BadRequest, "Price list does not exist");

			using var cancel = OperationCancelling;

			return await _repository.ItemsAsync(priceListId, cancel.Token);

		}

		[HttpGet("{id}/[action]")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(PriceListDto))]
		[ProducesResponseType(StatusCodes.Status400BadRequest)]
		public async Task<IActionResult> Content([FromRoute(Name = "id")] Guid priceListId)
		{
			using var cancel = OperationCancelling;

			var result = await _repository.ContentAsync(priceListId);

			if (result == null)
				return BadRequest($"Price list with id {priceListId} does not exist");

			return Ok(result);
		}
	}
}