create proc DeliveryServiceActionCreate 
(
	@ServiceId			int,					-- Идентификатор ТК
	@ActionsTypeId		int,					-- Идентификатор типа действия
	@ObjectId			varchar(50),			-- Идентификатор объекта, связанного с операцией
	@Success			bit,					-- Действие выполнено успешно
	@Comments			nvarchar(255),			-- Комментарий
	@AuthorId			uniqueidentifier,		-- Идентификатор автора
	-- Out-параметры
	@ErrorMes		nvarchar(255) out			-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''
		
	begin try

		-- Создаем действие
		insert ApiDeliveryServiceUserActions (ServiceId, ActionsTypeId, ObjectId, Success, Comments, AuthorId)
		values (@ServiceId, @ActionsTypeId, @ObjectId, @Success, @Comments, @AuthorId)

		return 0
	end try
	begin catch		
		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры DeliveryServiceActionCreate!'		
		return 1
	end catch

end
