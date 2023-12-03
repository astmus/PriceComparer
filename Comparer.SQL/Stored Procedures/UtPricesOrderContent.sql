create proc UtPricesOrderContent
(
	@OrderId	uniqueidentifier,
	@Date		DateTime	
)
as
begin

	if @Date is null  
		set @Date = getdate()

	-- РќР°С…РѕРґРёРј РїРѕСЃР»РµРґРЅРёР№ Р°РєС‚СѓР°Р»СЊРЅС‹Р№ РґРѕРєСѓРјРµРЅС‚ РґР»СЏ РєР°Р¶РґРѕРіРѕ С‚РѕРІР°СЂР°
	 	
	declare @ProductDoc table
	(
		ProductId	uniqueidentifier,
		DocId		int,
		DocNumber	nvarchar(64),		
		DocDate		datetime,
		Price		float,
		CurrencyId	int
	) 
	
	declare @ProductId uniqueidentifier

	declare Id_cursor cursor for
	select 
		ProductId 
	from 
		ClientOrdersContent c 
	where 
		c.ClientOrderId = @OrderId

	open Id_cursor
	fetch next from Id_cursor into @ProductId
	
	while @@fetch_status = 0  
	begin

		insert @ProductDoc(ProductId, DocId, DocNumber, DocDate, Price, CurrencyId)
		select top 1 p.ProductId, pd.Id, pd.Number, pd.Date, p.Price, p.CurrencyId
		from 
			UtPriceDocuments pd
				join UtPrices p on pd.Id = p.DocId 
		where  
			p.ProductId = @ProductId			and
			cast(pd.Date as Date) <= cast(@Date as Date) and
			p.PriceTypeId in (11)				and 
			pd.IsCancelled = 0					and
			p.Price > 0.0
		order by 
			pd.Date desc 

 		fetch next from Id_cursor into @ProductId

	end 

  close Id_cursor  
  deallocate Id_cursor 

	-- Р’С‹РІРѕРґРёРј С†РµРЅС‹

	select 
		r.ProductId		as 'ProductId',		-- Id С‚РѕРІР°СЂР°,
		r.Price			as 'Price',			-- Р¦РµРЅР°
		r.CurrencyId	as 'CurrencyId',	-- Р’Р°Р»СЋС‚Р°,
		r.DocNumber		as 'DocNumber',		-- РќРѕРјРµСЂ РґРѕРєСѓРјРµРЅС‚Р° 
		r.DocDate		as 'DocDate'		-- Р”Р°С‚Р°
	from @ProductDoc r
		--join UtPrices p on r.ProductId = p.ProductId  and r.DocId = p.DocId
    --where p.PriceTypeId in (1,2) 

end
