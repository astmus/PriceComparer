create proc DataMatrixCRPTPuttingDocumentRegDataEdit
(
    @Id							int,				-- Идентификатор документа
	@PublicId					nvarchar(128),		-- Индентификатор обмена
	@ActionDate					datetime,			-- Дата вывода из оборота
	@CRPTStatus					varchar(128),		-- Статус документа в ЦРПТ
	@StatusId					int,				-- Статус документа в ShopBase
	@Comments					nvarchar(255),		-- Комментарий
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

		update 
			DataMatrixCRPTPuttingDocuments
		set 
			PublicId				= @PublicId,
			CRPTStatus				= @CRPTStatus,
			StatusId				= @StatusId,
			Error					= @Error,
			RegTryCount				= RegTryCount + 1,
			Comments				= isnull(@Comments, Comments),
			AuthorId				= @AuthorId,
			ActionDate				= @ActionDate,
			ChangedDate				= getdate()	
		where 
			Id = @Id

		return 0
	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
