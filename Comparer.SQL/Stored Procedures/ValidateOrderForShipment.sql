create proc ValidateOrderForShipment
(
	@OrderId			uniqueidentifier,	-- Идентификатор заказа клиента
	@ErrorMes 			nvarchar(255) out	-- Сообщение об ошибке
) as
begin

		declare 
			@isEditing bit, 
			@blockShipment bit, 
			@editingAuthor nvarchar(200),
			@number nvarchar(50),
			@deliveryKind int,
			@fullyPaid bit
		
		select
			--@isEditing		= ISEDITING,
			@isEditing		= iif(l.OrderId is null, cast(0 as bit), cast(1 as bit)),
			@blockShipment	= o.BlockShipment,
			--@editingAuthor	= EDITINGAUTHOR,
			@editingAuthor = isnull(u.NAME, ''),
			@number			= case when o.PUBLICNUMBER <> '' then o.PUBLICNUMBER else cast(o.NUMBER as nvarchar(50)) end,
			@deliveryKind	= o.Deliverykind,
			@fullyPaid		= IIF(o.frozensum <= o.paidsum, 1, 0)
		from
			CLIENTORDERS o
			left join ClientOrdersLock l on l.OrderId = o.ID
			left join Users u on l.UserId = u.ID
		where 
			o.ID = @OrderId
		
		if @isEditing = 1
		begin
			set @ErrorMes = 'Заказ ' + @number + ' открыт на редактирование пользователем ' + @editingAuthor + '!'
			return 1
		end 
		if @blockShipment = 1
		begin
			set @ErrorMes = ' Стоит запрет на отгрузку заказа ' + @number + ', обратитесь к менеджеру!'
			return 1
		end
		if @deliveryKind = 36 AND @fullyPaid = 0
		begin
			set @ErrorMes = ' Заказ ' + @number + ' оплачен не полностью!'
			return 1
		end

		return 0
end
