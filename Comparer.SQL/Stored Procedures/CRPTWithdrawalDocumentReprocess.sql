create proc CRPTWithdrawalDocumentReprocess
(
	@AuthorId					uniqueidentifier	-- Идентификатор автора
)
as
begin

	set nocount on
	
	begin try

		update d
		set 
			d.PublicId				= null,

			d.StatusId				= 2, -- ожидает регистрации
			d.CRPTStatus			= null,
			d.CRPTStatusId			= 0,
			d.RegTryCount			= 2,

			d.Error					= null,

			d.Comments				= 'На повторную обработку',
			d.ChangedDate			= getdate(),	
			d.NextTryDate			= getdate()
		from
			#temp_Docs t
				join DataMatrixCRPTWithdrawalDocuments d on t.DocId = d.Id

			return 0
	end try
	begin catch		
		return 1
	end catch

end
