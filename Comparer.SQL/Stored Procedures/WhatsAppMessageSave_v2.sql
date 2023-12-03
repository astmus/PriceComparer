create proc WhatsAppMessageSave_v2
(	
	@OrderId			uniqueidentifier,		-- Идентификатор заказа
	@MessageStateId		int,					-- Статус сообщения
												-- 1 - Успешно отправлено
												-- 2 - Ошибка отправки
	@TemplateId			int,                    -- id шаблона сообщения
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибке
) as
begin
    
	set nocount on
	set @ErrorMes = ''

	begin try

		insert WhatsAppMessages (OrderId, MessageStateId, TemplateId) 
		values (@OrderId, @MessageStateId, @TemplateId)

		return 0

	end try
	begin catch	
		set @ErrorMes = error_message();
		return 1
	end catch

end
