create proc DeliveryServiceOrderEdit (
	@InnerId		uniqueidentifier,		-- Внутренний идентификатор заказа
	@StatusId		int,					-- Идентификатор статуса
	@AuthorId		uniqueidentifier,		-- Идентификатор автора
	-- Выходные параметры
	@ErrorMes		nvarchar(255) out		-- Сообщение об ошибках
) as
begin

	set @ErrorMes = ''
	set nocount on

	declare @trancount int
	select @trancount = @@TRANCOUNT

	begin try

		if @trancount = 0
			begin transaction

		-- Архивируем существующий заказ
		insert ApiDeliveryServiceOrdersArchive (InnerId, OuterId, ServiceId, StatusId, CreatedDate, ChangedDate, AuthorId)
		select o.InnerId, o.OuterId, o.ServiceId, o.StatusId, o.CreatedDate, o.ChangedDate, o.AuthorId
		from ApiDeliveryServiceOrders o
		where o.InnerId = @InnerId

		-- Обновляем существующий заказ
		update ApiDeliveryServiceOrders 
		set StatusId = @StatusId,
			AuthorId = @AuthorId,
			ChangedDate = getdate()
		where InnerId = @InnerId

		if @trancount = 0
			commit transaction
		return 0
	end try
	begin catch
		if @trancount = 0
			rollback transaction
		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры DeliveryServiceOrderEdit!'		
		return 1
	end catch

end
