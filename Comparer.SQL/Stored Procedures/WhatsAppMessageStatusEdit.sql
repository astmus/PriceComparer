create proc WhatsAppMessageStatusEdit
(	
	@ExternalMessageId		varchar(36),		-- Внешний идентификатор сообщения
	@StatusId				int,				-- Идентификатор статуса
												-- 0 - Не определен
												-- 1 - В очереди на отправку
												-- 2 - Отправлено
												-- 3 - Ошибка
	@ErrorCode				int,				-- Код ошибки
	@ErrorDescription		varchar(4000)		-- Описание ошибки
) as
begin
	begin try

		begin transaction

			-- Отправлено
			if @StatusId = 2 begin
	
				update 
					WhatsAppTemplateMessages
				set 
					StatusId = @StatusId
				where 
					ExternalId = @ExternalMessageId;

			end else
			-- Ошибка
			if @StatusId = 3 begin
	
				update 
					WhatsAppTemplateMessages
				set 
					StatusId			= @StatusId,
					ErrorCode			= @ErrorCode,
					ErrorDescription	= @ErrorDescription
				where 
					ExternalId = @ExternalMessageId;

			end
		commit transaction
	end try
	begin catch
		if @@trancount > 0
			rollback transaction

        declare @ErrorMessage nvarchar(max), @ErrorSeverity int, @ErrorState int
        select @ErrorMessage = error_message(), @ErrorSeverity = error_severity(), @ErrorState = error_state()
        raiserror(@ErrorMessage, @ErrorSeverity, @ErrorState)
	end catch
end
