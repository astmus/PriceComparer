using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Repositories;

using LinqToDB;

using Microsoft.AspNetCore.Mvc;
using Comparer.CollectionExtensions;
using Microsoft.AspNetCore.Http;

namespace Comparer.Api.Controllers
{

	public class PriceListController : BaseController
	{
		protected override ILogger log => GetLogger<PriceListController>();
		IPriceListRepository _repository;

		public PriceListController(IPriceListRepository repositroy) : base(repositroy)
			=> _repository = repositroy;


		[HttpGet("{id}")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(PriceListData))]
		[ProducesDefaultResponseType]
		public async Task<ActionResult<PriceListData>> Get([FromRoute(Name = "id")] Guid priceListId)
		{
			using var cancel = OperationCancelling;
			if (await _repository.RawQuery<PriceListData>().FirstOrDefaultAsync(list => list.Id == priceListId, cancel.Token) is PriceListData info)
				return Ok(info);

			LogError($"Price list with id {priceListId} does not exist");
			return BadRequest("Wrong price list id");
		}

		[HttpGet("{id}/[action]")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(IEnumerable<PriceListItem>))]
		[ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
		[ProducesResponseType(StatusCodes.Status204NoContent)]
		[ProducesDefaultResponseType]
		public async Task<IActionResult> Items([FromRoute(Name = "id")] Guid priceListId)
		{
			using var cancel = OperationCancelling;

			if (!await _repository.ItemExistAsync(list => list.ID == priceListId, cancel.Token))
				return BadRequest("Price list does not exist");

			var items = await _repository.ItemsAsync(priceListId, cancel.Token);
			return items switch
			{
				_ when items.IsEmpty() => NoContent(),
				_ => Ok(items)
			};
		}

		[HttpGet("{id}/[action]")]
		[ProducesResponseType(StatusCodes.Status200OK, Type = typeof(PriceListDto<PriceListProduct>))]
		[ProducesDefaultResponseType]
		public async Task<IActionResult> Content([FromRoute(Name = "id")] Guid priceListId)
		{
			using var cancel = OperationCancelling;

			var result = await _repository.ContentAsync(priceListId, cancel.Token);

			return result switch
			{
				null => BadRequest($"Price list with id {priceListId} does not exist"),
				_ when result.Items.IsEmpty() => NoContent(),
				_ => Ok(result)
			};
		}
	}
}