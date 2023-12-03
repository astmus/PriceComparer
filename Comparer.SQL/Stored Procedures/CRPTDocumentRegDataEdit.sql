create proc CRPTDocumentRegDataEdit
(
	@Id							int,					-- Идентификатор документа
	@CRPTNumber					nvarchar(500),			-- Номер документа в ЦРПТ
	@CRPTCreatedDate			dateTime,				-- Дата создания документа в ЦРПТ
	@Comments					nvarchar(255),			-- Комментарий
	@Error					    nvarchar(4000),			-- Сообщение об ошибке
	@AuthorId					uniqueidentifier,		-- Идентификатор автора
	-- Out-параметры
	@ErrorMes					nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on
	set @ErrorMes = ''
	
	declare
		@now datetime = getdate()

	begin try
		
		if @Id is not null begin

			update d
			set
				d.CRPTNumber		= @CRPTNumber,
				d.CRPTCreatedDate	= @CRPTCreatedDate,
				d.Comments			= isnull(@Comments, d.Comments),
				d.Error				= isnull(@Error, d.Error),
				d.AuthorId			= @AuthorId,
				d.ChangedDate		= @now
			from 
				CRPTDocuments d
			where 
				d.Id = @Id
		
		end
		else
		begin

			set @ErrorMes = 'Регистрационные данные документа не обновлены! Не определен идентификатор.'
			return 1

		end

		return 0
	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
