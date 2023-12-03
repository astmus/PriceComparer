create proc CRPTWithEDODocumentLinkCreate
(
	@CRPTDocId					int,					-- Идентификатор документа из ЦРПТ
	@EDODocId					int,					-- Идентификатор документа из ЭДО

	@AuthorId					uniqueidentifier,		-- Идентификатор автора
	-- Out-параметры
	@ErrorMes					nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on
	set @ErrorMes = ''
	
	begin try
		
		-- 1. Вставляем запись, только если ее еще не существует

		insert CRPTWithEDODocumentLinks 
		(
			CRPTDocId, EDODocId
		)
		select
			t.CRTPDocId, t.EDODocId
		from 
		(
			select
				@CRPTDocId		as 'CRTPDocId',
				@EDODocId		as 'EDODocId'
		) t
			left join CRPTWithEDODocumentLinks l on l.CRPTDocId = t.CRTPDocId and l.EDODocId = t.EDODocId
		where
			l.CRPTDocId is null


		return 0
	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
