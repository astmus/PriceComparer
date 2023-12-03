create proc WhatsAppMessageToBufferSave
(	
	@ExternalMessageId		varchar(36),
	@ErrorMes				varchar(4000) out
) as
begin

	set @ErrorMes = ''

	begin try

		insert into ClientDeliveredWhatsAppTemplatesBuffer (MessageId, PhoneNumber)
		select Id, PhoneNumber from WhatsAppTemplateMessages where ExternalId = @ExternalMessageId

		-- Если вставки записи не было
		if @@rowcount = 0 begin
			
			set @ErrorMes = 'Insert operation did not happen!'
			return 1

		end
		
		return 0

	end try
	begin catch
		set @ErrorMes = error_message()
		return 1
	end catch

end
