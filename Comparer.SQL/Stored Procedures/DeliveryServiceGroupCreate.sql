create proc DeliveryServiceGroupCreate 
(
	@OuterId		varchar(50),			-- Идентификатор группы в ЛК ТК
	@Name			varchar(50),			-- Имя группы
	@ServiceId		int,					-- Идентификатор ТК
	@TypeId			int,					-- Идентификатор типа
	@CategoryId		int,					-- Идентификатор категории
	@ExpectedDate	datetime,				-- Дата планируемой отправки
	@AccountId		int,					-- Идентификатор аккаунта
	@AuthorId		uniqueidentifier,		-- Идентификатор автора
	-- Выходные параметры
	@NewId			int out,				-- Идентификатор созданной группы
	@ErrorMes		nvarchar(255) out		-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @NewId = 0
	set @ErrorMes = ''

	declare @trancount int
	select @trancount = @@TRANCOUNT

	begin try

		if @trancount = 0
			begin transaction
		
		-- Создаем запись в основной таблице			
		insert ApiDeliveryServiceGroups (OuterId, Name, ServiceId, AccountId, AuthorId, StatusId)
		values (@OuterId, @Name, @ServiceId, @AccountId, @AuthorId, 1)

		set @NewId = @@IDENTITY

		-- Создаем запись во вспомогательной таблице
		insert ApiDeliveryServiceGroupsInfo (Id, TypeId, CategoryId, ExpectedDate)
		values (@NewId, @TypeId, @CategoryId, @ExpectedDate)

		-- Если передан список заказов
		if exists (select 1 from #tkOrderIds) begin

			insert ApiDeliveryServiceGroupOrderLinks (OrderId, GroupId)
			select i.OrderId, @NewId
			from #tkOrderIds i

		end
		
		if @trancount = 0
			commit transaction
		return 0
	end try
	begin catch
		if @trancount = 0
			rollback transaction
		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры DeliveryServiceGroupCreate!'		
		return 1
	end catch
	
end
