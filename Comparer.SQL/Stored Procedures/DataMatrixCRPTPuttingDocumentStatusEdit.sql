create proc DataMatrixCRPTPuttingDocumentStatusEdit
(
    @Id							int,				-- Идентификатор документа
	@CRPTStatus					varchar(128),		-- Статус документа в ЦРПТ
	@StatusId					int,				-- Статус документа в ShopBase
	@AuthorId					uniqueidentifier,	-- Идентификатор автора
	@Error						nvarchar(1000),     -- Сообщение об ошибке  
	-- Out-параметры
	@ErrorMes					nvarchar(4000) out	-- Сообщение об ошибках
)
as
begin

	set nocount on
	set @ErrorMes = ''
	
	begin try

			declare @CRPTStatusId int

			select @CRPTStatusId=Id
			from CRPTDocumentStatuses
			where Value=@CRPTStatus	

			update DataMatrixCRPTPuttingDocuments
			set 
				CRPTStatus				= @CRPTStatus,
				CRPTStatusId			= isnull(@CRPTStatusId,0),
				StatusId				= @StatusId,
				Error					= @Error,
				AuthorId				= @AuthorId,
				ChangedDate				= getdate()	
			where 
				Id = @Id

		if (@CRPTStatus = 'CHECKED_NOT_OK' and @StatusId = 3)
		begin
			update DataMatrixCRPTPuttingDocuments
			set 
				CRPTStatus				= null,
				CRPTStatusId			= 0,
				StatusId				= 2,
				PublicId				= null,
				Error					= null,
				AuthorId				= @AuthorId,
				NextTryDate				= dateadd(minute, ((RegTryCount - 1) * 4 + 1), getdate()),
				Comments				= 'Пересоздание №' + cast(RegTryCount as nvarchar(2)) + ' для ЦРПТ', 
				ChangedDate				= getdate()	
			where 
				Id = @Id
		end
		return 0

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
