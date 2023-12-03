create proc OrderContentForRozlivView 
(
	@OrderId		uniqueidentifier		-- Идентификатор заказа
)as
begin

	select 
		*
	from
	(
		select 
			p.ID							as 'Id',				-- Идентификатор товара
			p.SKU							as 'SKU',				-- Артикул товара
			m.[NAME]						as 'Brand',				-- Бренд
			p.[NAME]						as 'Name',				-- Наименование товара
			isnull(p.BASEPRICE,0)			as 'BasePrice',			-- Цена закупки базовая
			isnull(p.PRICE,0)				as 'Price',				-- Цена закупки
			p.DEFAULTCURRENCY				as 'Currency',			-- Валюта
			isnull(c.STOCK_QUANTITY, 0) - isnull(item.ProductQuantity, 0)
											as 'Quantity'			-- Доступное количество
		from CLIENTORDERSCONTENT c with (nolock)
			join PRODUCTS p with (nolock) on p.ID = c.PRODUCTID
			join MANUFACTURERS m with (nolock) on m.ID = p.MANID
			left join	
			(
				select
					rd.OrderId,
					rdi.ProductId,
					sum(rdi.Quantity)		as 'ProductQuantity'
								
				from RozlivUtDocuments rd
					join RozlivUtDocumentItems rdi on rdi.DocId = rd.Id 
				where
					rd.ConfirmedByUt = 0
					and rd.OrderId = @OrderId
				group by
					rd.OrderId, rdi.ProductId
							
			) item on item.OrderId = c.CLIENTORDERID and item.ProductId = c.PRODUCTID
		where
			c.CLIENTORDERID = @OrderId
	) t
	where
		t.Quantity > 0
	order by 
		t.Brand, t.[Name]

end
