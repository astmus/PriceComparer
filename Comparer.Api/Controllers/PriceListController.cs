using System.Text.Json;

using Comparer.Api.Filters;
using Comparer.DataAccess.Abstractions.Common;
using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Repositories;

using LinqToDB;

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;

namespace Comparer.Api.Controllers
{

	public class PriceListController : BaseController
	{
		protected override ILogger log => GetLogger<PriceListController>();

		IPriceListRepository _repository;
		public PriceListController(IPriceListRepository repositroy)
			=> _repository = repositroy;


		[HttpGet]
		[ProducesResponseType(StatusCodes.Status200OK)]
		public async Task<IEnumerable<DataUnit>> Get()
		{
			var items = await _repository.RawQuery<DataUnit>().ToListAsync();
			return items;
		}

		[HttpGet("{id}")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(PriceListInfo))]
		[ProducesDefaultResponseType]
		public async Task<ActionResult<PriceListInfo>> Get([FromRoute(Name = "id")] Guid priceListId)
		{
			if (await _repository.RawQuery<PriceListInfo>().FirstOrDefaultAsync(list => list.Id == priceListId) is PriceListInfo info)
				return Ok(info);
			else
			{
				LogError($"Price list with id {priceListId} does not exist");
				return BadRequest("Wrong price list id");
			}
		}

		[HttpGet("{id}/[action]")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IEnumerable<PriceListItem>))]
		public async Task<IEnumerable<ListItem>> Items([FromRoute(Name = "id")] Guid priceListId)
		{
			if (!await _repository.ItemExistAsync(list => list.ID == priceListId))
				ThrowClient(StatusCodes.Status404NotFound, "Price list does not exist");

			using var cancel = OperationCancelling;

			var items = await _repository.ItemsAsync(priceListId, cancel.Token);
			return items;

		}

		[HttpGet("{id}/[action]")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(PriceListDto))]
		[ProducesDefaultResponseType]
		public async Task<IActionResult> Content([FromRoute(Name = "id")] Guid priceListId)
		{
			using var cancel = OperationCancelling;

			var result = await _repository.ContentAsync(priceListId, cancel.Token);

			if (result == null)
				ThrowClient(StatusCodes.Status404NotFound, $"Price list with id {priceListId} does not exist");

			return Ok(result);
		}
	}
}