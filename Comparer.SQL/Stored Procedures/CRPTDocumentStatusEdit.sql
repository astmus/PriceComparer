create proc CRPTDocumentStatusEdit
(
	@Id							int,					-- Идентификатор документа

	@CRPTNumber					nvarchar(500),			-- Номер документа в ЦРПТ
	@CRPTStatus					varchar(128),			-- Статус документа в ЦРПТ
	
	@StatusId					int,					-- Статус документа
	
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
				d.StatusId		= @StatusId,
				d.CRPTStatus	= isnull(@CRPTStatus, d.CRPTStatus),
				d.Error			= isnull(@Error, iif(@StatusId = 1, null, d.Error)),
				d.ChangedDate	= @now
			from 
				CRPTDocuments d
			where 
				d.Id = @Id
		
		end
		else
		if @CRPTNumber is not null begin

			update d
			set
				d.StatusId		= @StatusId,
				d.CRPTStatus	= isnull(@CRPTStatus, d.CRPTStatus),
				d.ChangedDate	= @now
			from 
				CRPTDocuments d
			where 
				d.CRPTNumber = @CRPTNumber
		
		end
		else
		begin

			set @ErrorMes = 'Статус документа не обновлен! Не определен идентификатор.'
			return 1

		end

		return 0
	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
