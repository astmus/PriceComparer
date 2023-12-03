create proc SUZOrderForLabelPrintView
(
	@GTIN			nvarchar(14),		-- GTIN
	@ProductId		uniqueidentifier,	-- Идентификатор товара
	@Sku			int					-- Артикул товара
)
as
begin

	if @GTIN is null begin
		
		if @ProductId is not null
			select @GTIN = b.Barcode from CRPTTechCardBarcodes b where b.ProductId = @ProductId
		else
			select @GTIN = b.Barcode from CRPTTechCardBarcodes b join Products p on p.ID = b.ProductId and p.SKU = @Sku

	end

	if @GTIN is null
		return

	select 
		o.Id,
		o.PublicId,
		o.IsActive,		
		o.StatusId,
		o.CreatedDate,
		i.Id							as 'ItemId',
		i.GTIN,
		i.Quantity,
		--isnull(dm.Rest, 0) as 'Rest'
		i.Quantity - i.PrintedQuantity	as 'Rest'
	from 
		SUZOrders o
			join SUZOrderItems i on i.OrderId = o.Id	and 
									o.IsActive = 1		and 
									i.IsActive = 1		and 
									o.StatusId = 1
									
			/*left join 
			(
				select
					i.Id, count(*) as 'Rest'
				from SUZOrderItems i
						join SUZOrderItemDataMatrixes dm on dm.ItemId = i.Id
				where
					i.IsActive = 1 and
					dm.IsPrinted = 0
				group by
					i.Id
			) dm on dm.Id = i.Id*/
	where
		i.GTIN = @GTIN and
		(i.Quantity - i.PrintedQuantity) > 0
	order by
		o.CreatedDate

end
