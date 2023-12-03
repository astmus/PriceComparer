create proc DeliveryServiceGroupDelete 
(
	@InnerId		int,					-- Внутренний идентификатор группы
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

		-- Удаляем группу
		delete ApiDeliveryServiceGroups where Id = @InnerId
		-- Удаляем доп информацию о группе
		delete ApiDeliveryServiceGroupsInfo where Id = @InnerId
		-- Удаляем связи с группой
		delete ApiDeliveryServiceGroupOrderLinks where GroupId = @InnerId

		if @trancount = 0
			commit transaction
		return 0
	end try
	begin catch
		if @trancount = 0
			rollback transaction
		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры DeliveryServiceGroupDelete!'		
		return 1
	end catch

end
