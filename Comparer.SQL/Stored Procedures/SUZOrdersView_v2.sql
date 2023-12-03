create proc SUZOrdersView_v2
(
	@Id				int,				-- Идентификатор заказа в ShopBase
	@PublicId		nvarchar(128),		-- Идентификатор заказа в СУЗ
	@GTIN			nvarchar(14),		-- GTIN
	@IsActive		bit,				-- Активные
	@StatusId		int,				-- Идентификатор статуса
	@Sku			int					-- Артикул
)
as
begin

	if @Id is not null begin

		select 
			o.Id,
			o.PublicId,
			o.IsActive,
			o.StatusId,
			o.SourceId,
			o.ClosedDate,
			o.CreatedDate,
			o.MustBeClosed,
			o.Error
		from 
			SUZOrders o
		where
			o.Id = @Id

	end else
		if (@Sku is not null)
		begin
			declare @ProductId uniqueidentifier
			select @ProductId=Id 
			from Products 
			where Sku=@Sku

		select
			o.Id,
			o.PublicId,
			o.IsActive,
			o.StatusId,
			o.SourceId,
			o.ClosedDate,
			o.CreatedDate,
			o.MustBeClosed,
			o.Error
		from 
			SUZOrders o
			join SUZOrderItems i on i.OrderId=o.Id 
		where	
		  (@ProductId is null or (@ProductId is not null and @ProductId=i.ProductId)) and
		  (@IsActive is null or (@IsActive is not null and @IsActive=o.IsActive)) and
		  (@StatusId is null or (@StatusId is not null and o.StatusId = @StatusId)) 

	end
		if @GTIN is null begin

		select 
			o.Id,
			o.PublicId,
			o.IsActive,
			o.StatusId,
			o.SourceId,
			o.ClosedDate,
			o.CreatedDate,
			o.MustBeClosed,
			o.Error
		from 
			SUZOrders o
		where
			(@IsActive is null or (@IsActive is not null and o.IsActive = @IsActive)) and
			(@StatusId is null or (@StatusId is not null and o.StatusId = @StatusId)) and
			(@PublicId is null or (@PublicId is not null and o.PublicId = @PublicId))
		order by
			o.CreatedDate desc

	end 
	 else begin
		select 
			o.Id,
			o.PublicId,
			o.IsActive,
			o.StatusId,
			o.SourceId,
			o.ClosedDate,
			o.CreatedDate,
			o.MustBeClosed,
			o.Error
		from 
			SUZOrders o
		where
			(@IsActive is null or (@IsActive is not null and o.IsActive = @IsActive)) and
			(@StatusId is null or (@StatusId is not null and o.StatusId = @StatusId)) and
			(@PublicId is null or (@PublicId is not null and o.PublicId = @PublicId)) and 
			o.Id in 
			(
				select i.OrderId
				from 
					SUZOrderItems i
				where
					i.GTIN = @GTIN
			)
		order by
			o.CreatedDate desc

	end

end
