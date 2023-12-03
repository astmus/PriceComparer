create proc DeliveryServiceOrdersAddToGroup 
(
	@InnerId		int,				-- Внутренний идентификатор группы
	-- Выходные параметры
	@ErrorMes		nvarchar(255) out		-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''

	if not exists (select 1 from ApiDeliveryServiceGroups where Id = @InnerId) begin
		set @ErrorMes = 'Ошибка во время добавления заказов в группу! Группа не найдена.'		
		return 1
	end

	declare @trancount int
	select @trancount = @@TRANCOUNT

	begin try

		if @trancount = 0
			begin transaction
		
		-- Если передан список заказов
		if exists (select 1 from #tkOrderIds) begin

			insert ApiDeliveryServiceGroupOrderLinks(OrderId, GroupId)
			select i.OrderId, @InnerId
			from #tkOrderIds i

		end
		
		if @trancount = 0
			commit transaction
		return 0
	end try
	begin catch
		if @trancount = 0
			rollback transaction
		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры DeliveryServiceOrdersAddToGroup!'		
		return 1
	end catch

end
