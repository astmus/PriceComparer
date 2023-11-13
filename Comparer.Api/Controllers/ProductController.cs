using Comparer.DataAccess.Dto;
using Comparer.DataAccess.Repositories;
using Comparer.DataAccess.Requests;

using LinqToDB;
using LinqToDB.Common;

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;

namespace Comparer.Api.Controllers
{
	public class ProductController : BaseController
	{

		IProductRepository _repository;
		public ProductController(IProductRepository repository) : base(repository)
		{
			_repository = repository;
		}

		[HttpGet("{id}")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status204NoContent)]
		[ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
		[ProducesDefaultResponseType]
		public async Task<ActionResult<IEnumerable<PriceListProduct>>> Get([FromRoute(Name = "id")] Guid productId, [FromQuery] Guid? basePriceId)
		{
			Log("Producst" + productId + "Get");

			using var cancel = OperationCancelling;
			if (await _repository.ItemExistAsync(prod => prod.Id == productId, cancel.Token))
			{
				var pricesProducts = await _repository.PriceListProducts.
																				Where(p => p.Product.Id == productId).
																				ToListAsync(cancel.Token);

				if (pricesProducts.IsNullOrEmpty())
					return NoContent();

				return Ok(pricesProducts.OrderBy(o => basePriceId switch
				{
					Guid baseId when o.PriceList.Id == baseId && o.Product.Id == productId => double.MinValue,
					_ => o.Price
				}));
			}
			else
				return BadRequest("Product does not exist");
		}


		[HttpGet("diff")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
		[ProducesDefaultResponseType]
		public async Task<ActionResult<IEnumerable<PriceProductDiffDto>>> DiffAnalizeAsync([FromQuery] CompareRequest request)
		{
			if (request.BasePriceId is not Guid)
				return BadRequest("Empty base price list id");

			var query = diffQuery(request.BasePriceId.Value, request.Kind == CompareKind.OtherMinPrice);
			using var cancel = OperationCancelling;

			var diffs = await _repository.RawQueryAsync<PriceProductDiff>(query, cancel.Token);
			var productGrouping =
				from diff in diffs
				group diff by (diff.Id) into productGroup
				orderby productGroup.Key
				select productGroup;

			var priceListsGrouping = from list in diffs
									 group list by (list.PriceListId, list.PriceListName, list.DisID);

			var listData = priceListsGrouping.Select(s => new PriceListData()
			{
				Id = s.Key.PriceListId ?? default,
				Name = s.Key.PriceListName,
				DisID = s.Key.DisID
			}).ToList();


			List<PriceProductDiffDto> result = new List<PriceProductDiffDto>(productGrouping.Count());
			PriceProductDiffDto resItem = new PriceProductDiffDto();
			foreach (var prod in productGrouping)
			{
				resItem = resItem with
				{
					Id = prod.Key
				};

				foreach (var listProduct in prod)
				{
					result.Add(resItem with
					{
						PriceList = listData.FirstOrDefault(f => f.Name == listProduct.PriceListName),
						Price = listProduct.Price,
						BasePrice = listProduct.BasePrice,
						MinPrice = listProduct.MinPrice,
						MaxPrice = listProduct.MaxPrice
					});
				}
			}

			return result;
		}


		string diffQuery(Guid priceListId, bool onlyMin = false) => @$"
		declare @onlyMin bit = {Convert.ToInt16(onlyMin)};
			WITH Pricelistproducts AS (SELECT List.Id               Pricelistid,
								  Link.Catalogproductid Productid,
								  Rec.Recordindex       Itemid
							   FROM Links         Link
							   JOIN Pricesrecords Rec ON Link.Pricerecordindex = Rec.Recordindex
							   JOIN Prices        List ON Rec.Priceid = List.Id
),
	 Baseproducts
					   AS (
		 SELECT *
			 FROM Pricelistproducts
			 WHERE Pricelistid = '{priceListId}')
		,
	 Otherproducts
					   AS
		 (SELECT Prod.*,
				 Rec.Price                                                 Otherprice,
				 List.Name                                                 Pricelistname,
				 min(Rec.Price) OVER (PARTITION BY Productid)              Minprodprice,
				 max(Rec.Price) OVER (PARTITION BY Productid, Pricelistid) Maxprodprice,
				 Dist.Id                                                   Disid
			  FROM Pricelistproducts Prod
			  JOIN Pricesrecords     Rec ON Prod.Itemid = Rec.Recordindex
			  JOIN Prices            List ON Prod.Pricelistid = List.Id
			  JOIN Distributors      Dist ON List.Disid = Dist.Id
			  WHERE [DIST].[ACTIVE] = 1
				AND [LIST].[ISACTIVE] = 1
				AND [REC].[DELETED] <> 0
				AND [REC].[USED] = 1
				AND [LIST].[ID] != '{priceListId}')
		, Productsinfo AS (
	SELECT DISTINCT B.Productid                                          Id,
					P.Name,
					P.Childname,
					Rec.Price                                            Baseprice,
					X.*,
					Rank() OVER (PARTITION BY Id, BasePrice ORDER BY Pricelistname) Rnk
		FROM Baseproducts         B
		JOIN        Products      P ON B.Productid = P.Id
		JOIN        Pricesrecords Rec ON B.Itemid = Rec.Recordindex
		OUTER APPLY (
						SELECT O.Otherprice,
							   O.Pricelistid,
							   O.Pricelistname,
							   O.Minprodprice,
							   O.Maxprodprice,
							   O.Disid
							FROM Otherproducts O
							WHERE O.Productid = B.Productid AND (@onlyMin = 0 OR O.OtherPrice < rec.PRICE )
					)             X
		WHERE Otherprice = Minprodprice
)
SELECT Id,	   		
		IIF (OtherPrice = 0,NULL,OtherPrice) Price,
		Baseprice,
		Pricelistid,
		PriceListName,
		IIF(minProdPrice = 0, NULL, minProdPrice) as MinPrice,
		IIF(maxProdPrice = 0, NULL, maxProdPrice) as MaxPrice,
	    Disid
	   
	FROM Productsinfo
	WHERE Rnk = 1
						";
	}
}