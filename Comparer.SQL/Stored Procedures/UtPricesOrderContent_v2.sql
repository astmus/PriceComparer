create proc UtPricesOrderContent_v2
(
	@OrderId	uniqueidentifier
)
as
begin

	-- Р”Р°С‚Р° РѕС‚РіСЂСѓР·РєРё
	declare @Date DateTime
	set @Date=null

	select @Date=d.WmsCreateDate
	from ClientOrders o
		join WmsShipmentDocuments d on d.PublicId = o.ID and d.DocStatus = 10
	where
		o.Id = @OrderId

	if (@Date is null)
	set @Date=getdate()

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
		
		-- РџСЂРѕРІРµСЂРєР° РЅР° РјР°СЂРєРёСЂРѕРІРєСѓ
		   if  exists (select 1 from OrderContentDataMatrixes where OrderId=@OrderId and ProductId=@ProductId)
		   begin
				select @Date= max(r.CRPTCreatedDate)   
				from
				(
					select t.DataMatrix, min(t.CRPTCreatedDate) as 'CRPTCreatedDate'
					from
					(
						select distinct d.CRPTCreatedDate, i.DataMatrix
						from CRPTDocuments d
							join CRPTDocumentItems i on i.DocId = d.Id
							join OrderContentDataMatrixes  m on m.ProductId=i.ProductId
						where
							d.CRPTType in ('LP_ACCEPT_GOODS','UNIVERSAL_TRANSFER_DOCUMENT')
							and d.StatusId = 1
							and i.ProductId=@ProductId
							and m.OrderId=@OrderId
					) t
					group by t.DataMatrix
				) as r
				group by r.CRPTCreatedDate
			end

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
