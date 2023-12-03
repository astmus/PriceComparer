create proc CRPTDocumentWithPurchaseTaskLinkDelete
(
	@CRPTDocId					int,					-- Идентификатор документа из ЦРПТ
	@AuthorId					uniqueidentifier,		-- Идентификатор автора
	-- Out-параметры
	@ErrorMes					nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on
	set @ErrorMes = ''
	
	begin try
		
		-- 1. Удаляем запись

		delete 
			l
		from
			CRPTDocumentWithPurchaseTaskLinks l
				join #TaskIds t on t.TaskId = l.TaskId
		where
			CRPTDocId = @CRPTDocId

		return 0
	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
