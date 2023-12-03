create proc DeliveryServiceActionView
(
	@ObjectId			varchar(50),			-- Идентификатор объекта
	@ServiceId			int,					-- Идентификатор ТК
	@ActionsTypeId		int,					-- Идентификатор типа действия
	@Success			bit,					-- Действие выполнено успешно
	@AuthorId			uniqueidentifier		-- Идентификатор автора	
) as
begin

	if (@ObjectId Is Not Null) AND (@ServiceId Is Not Null) begin

		select a.ServiceId, a.ActionsTypeId, a.ObjectId, a.Success, a.Comments, a.AuthorId, a.CreatedDate
		from ApiDeliveryServiceUserActions a
		where	
			a.ObjectId = @ObjectId
			AND a.ServiceId = @ServiceId

	end else begin

		select a.ServiceId, a.ActionsTypeId, a.ObjectId, a.Success, a.Comments, a.AuthorId, a.CreatedDate
		from ApiDeliveryServiceUserActions a
		where	(@ServiceId		is null or (@ServiceId		is not null and a.ServiceId = @ServiceId)) and
				(@ActionsTypeId is null or (@ActionsTypeId is not null and a.ActionsTypeId = @ActionsTypeId)) and
				(@Success		is null or (@Success is not null and a.Success = @Success)) and
				(@AuthorId		is null or (@AuthorId is not null and a.AuthorId = @AuthorId))
		order by a.CreatedDate desc

	end
end
