create proc WhatsAppOrderMessageSave
(	
	@OrderId				uniqueidentifier,
	@ExternalMessageId		varchar(36),
	@MessageStatusId		int,
	@MessageTemplateId		int,
	@PhoneNumber			varchar(50),
	@AuthorId				uniqueidentifier,
	@Message				nvarchar(max),
	@ErrorMes				varchar(4000) out
) as
begin

	set @ErrorMes = ''

	declare 
		@trancount int
	select @trancount = @@trancount

	begin try

		if @trancount = 0
			begin transaction

			insert WhatsAppTemplateMessages 
			(
				ExternalId, StatusId, TemplateId, PhoneNumber, [Message]
			)
			values 
			(
				@ExternalMessageId, @MessageStatusId, @MessageTemplateId, @PhoneNumber, @Message
			)

			declare 
				@MessageId int = @@identity;

			insert WhatsAppOrderMessagesHistory 
			(
				OrderId, MessageId, AuthorId
			)
			values 
			(
				@OrderId, @MessageId, @AuthorId
			)

		if @trancount = 0
			commit transaction

		return 0

	end try
	begin catch
		if @trancount = 0
			rollback transaction

		set @ErrorMes = error_message()
		return 1
	end catch
end
