create proc DataMatrixCRPTWithdrawalDocumentListStatusEdit
(
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

	declare
		@CRPTStatusId	 int		-- Идентификатор статуса ЦРПТ в базе данных
	select  @CRPTStatusId = s.Id from CRPTDocumentStatuses s where s.Value = @CRPTStatus

	-- 1.0 Вставляем обновленные данные из ЦРПТ
	if (@StatusId <> 2) begin
		update d			
		set 
			CRPTStatus				= @CRPTStatus,
			CRPTStatusId			= Isnull(@CRPTStatusId, 0), 
			StatusId				= @StatusId,
			Error					= @Error,
			AuthorId				= @AuthorId,
			ChangedDate				= getdate()	
		from 
			#temp_Docs t
				join DataMatrixCRPTWithdrawalDocuments d on t.DocId = d.Id

	end

	--2.0 При ошибке обработки в ЦРПТ ставим документ на повторную обработку
	if ( (@StatusId = 2) or (@StatusId = 3 and @CRPTStatus = 'CHECKED_NOT_OK') ) begin

		update d
		set 
			d.PublicId				= null,

			d.StatusId				= 2, -- ожидает регистрации
			d.CRPTStatus			= null,
			d.CRPTStatusId			= 0,

			d.Error					= null,

			d.Comments				= 'Пересоздание №' + cast(d.RegTryCount as nvarchar(2)) + ' для ЦРПТ',
			d.ChangedDate			= getdate(),	
			d.NextTryDate			= dateadd(minute, ((d.RegTryCount - 1) * 4 + 1), getdate())
		from
			#temp_Docs t
				join DataMatrixCRPTWithdrawalDocuments d on t.DocId = d.Id
	end

		return 0
	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
