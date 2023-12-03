create proc DistributorApiOrdersContentView (	
	@OrderId			int,			-- Идентификатор заказа
	@ProductSku			int,			-- Артикул товара	
	@ProductOutSku		int,			-- Артикул товара поставщика	
	@Archived			bit				-- Архивные
) as
begin

	-- Если ищем в действующих
	if @Archived = 0 begin
	
		-- Если артикул товара задан
		if @ProductSku is not null begin
		
			select dc.OrderId, dc.PriceListId, dc.ProductId, dc.OutSku, dc.Quantity, dc.ReportDate, dc.Comment, pr.NAME as 'PriceListName', 				
				p.NAME as 'ProductName', p.CHILDNAME as 'ProductChildName', p.SKU, p.VIEWSTYLEID, m.ID as 'BrendId', m.NAME as 'BrendName'
			from DistributorsApiOrdersContent dc				
				join PRICES pr on pr.ID = dc.PriceListId
				join PRODUCTS p on p.ID = dc.ProductId
				join MANUFACTURERS m on m.ID = p.MANID
			where dc.OrderId = @OrderId and p.SKU = @ProductSku
					
		end else
		-- Если артикул товара поставщика задан
		if @ProductOutSku is not null begin
		
			select dc.OrderId, dc.PriceListId, dc.ProductId, dc.OutSku, dc.Quantity, dc.ReportDate, dc.Comment, pr.NAME as 'PriceListName', 				
				p.NAME as 'ProductName', p.CHILDNAME as 'ProductChildName', p.SKU, p.VIEWSTYLEID, m.ID as 'BrendId', m.NAME as 'BrendName'
			from DistributorsApiOrdersContent dc				
				join PRICES pr on pr.ID = dc.PriceListId
				join PRODUCTS p on p.ID = dc.ProductId
				join MANUFACTURERS m on m.ID = p.MANID
			where dc.OrderId = @OrderId and dc.OutSku = @ProductOutSku
					
		end else begin
		
			select dc.OrderId, dc.PriceListId, dc.ProductId, dc.OutSku, dc.Quantity, dc.ReportDate, dc.Comment, pr.NAME as 'PriceListName', 				
				p.NAME as 'ProductName', p.CHILDNAME as 'ProductChildName', p.SKU, p.VIEWSTYLEID, m.ID as 'BrendId', m.NAME as 'BrendName'
			from DistributorsApiOrdersContent dc				
				join PRICES pr on pr.ID = dc.PriceListId
				join PRODUCTS p on p.ID = dc.ProductId
				join MANUFACTURERS m on m.ID = p.MANID
			where dc.OrderId = @OrderId
			order by m.NAME, p.NAME, p.CHILDNAME
		
		end
	
	end else begin  -- Если ищем в архиве
			
		-- Если артикул товара задан
		if @ProductSku is not null begin
		
			select dc.OrderId, dc.PriceListId, dc.ProductId, dc.OutSku, dc.Quantity, dc.ReportDate, dc.Comment, pr.NAME as 'PriceListName', 				
				p.NAME as 'ProductName', p.CHILDNAME as 'ProductChildName', p.SKU, p.VIEWSTYLEID, m.ID as 'BrendId', m.NAME as 'BrendName'
			from DistributorsApiOrdersContentArchive dc				
				join PRICES pr on pr.ID = dc.PriceListId
				join PRODUCTS p on p.ID = dc.ProductId
				join MANUFACTURERS m on m.ID = p.MANID
			where dc.OrderId = @OrderId and p.SKU = @ProductSku and dc.IsArchive = 0
					
		end else
		-- Если артикул товара поставщика задан
		if @ProductOutSku is not null begin
		
			select dc.OrderId, dc.PriceListId, dc.ProductId, dc.OutSku, dc.Quantity, dc.ReportDate, dc.Comment, pr.NAME as 'PriceListName', 				
				p.NAME as 'ProductName', p.CHILDNAME as 'ProductChildName', p.SKU, p.VIEWSTYLEID, m.ID as 'BrendId', m.NAME as 'BrendName'
			from DistributorsApiOrdersContentArchive dc				
				join PRICES pr on pr.ID = dc.PriceListId
				join PRODUCTS p on p.ID = dc.ProductId
				join MANUFACTURERS m on m.ID = p.MANID
			where dc.OrderId = @OrderId and dc.OutSku = @ProductOutSku and dc.IsArchive = 0
					
		end else begin
		
			select dc.OrderId, dc.PriceListId, dc.ProductId, dc.OutSku, dc.Quantity, dc.ReportDate, dc.Comment, pr.NAME as 'PriceListName', 				
				p.NAME as 'ProductName', p.CHILDNAME as 'ProductChildName', p.SKU, p.VIEWSTYLEID, m.ID as 'BrendId', m.NAME as 'BrendName'
			from DistributorsApiOrdersContentArchive dc				
				join PRICES pr on pr.ID = dc.PriceListId
				join PRODUCTS p on p.ID = dc.ProductId
				join MANUFACTURERS m on m.ID = p.MANID
			where dc.OrderId = @OrderId and dc.IsArchive = 0
			order by m.NAME, p.NAME, p.CHILDNAME
		
		end		
	
	end

end
