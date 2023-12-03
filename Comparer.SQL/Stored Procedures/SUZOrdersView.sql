create proc SUZOrdersView
(
	@Id				int,				-- Идентификатор заказа в ShopBase
	@PublicId		nvarchar(128),		-- Идентификатор заказа в СУЗ
	@GTIN			nvarchar(14),		-- GTIN
	@IsActive		bit,				-- Активные
	@StatusId		int					-- Идентификатор статуса
)
as
begin

	if @Id is not null begin

		select 
			o.Id,
			o.PublicId,
			o.IsActive,
			o.StatusId,
			o.ClosedDate,
			o.CreatedDate
		from 
			SUZOrders o
		where
			o.Id = @Id

	end else
	if @GTIN is null begin

		select 
			o.Id,
			o.PublicId,
			o.IsActive,
			o.StatusId,
			o.ClosedDate,
			o.CreatedDate
		from 
			SUZOrders o
		where
			(@IsActive is null or (@IsActive is not null and o.IsActive = @IsActive)) and
			(@StatusId is null or (@StatusId is not null and o.StatusId = @StatusId)) and
			(@PublicId is null or (@PublicId is not null and o.PublicId = @PublicId))
		order by
			o.CreatedDate desc

	end else begin

		select 
			o.Id,
			o.PublicId,
			o.IsActive,
			o.StatusId,
			o.ClosedDate,
			o.CreatedDate
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
