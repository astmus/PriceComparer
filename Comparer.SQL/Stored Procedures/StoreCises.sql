create proc StoreCises
(
	-- Out-параметры
	@ErrorMes					nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on
	set @ErrorMes = ''
	
	begin try

		insert _DataMatrixesApi
			(ProductName, DataMatrix, LastDocumentId, EmissionDate, [Status])
		select 
			ProductName, DataMatrix, LastDocumentId, EmissionDate, [Status]
		from
			#cises i

		return 0
	end try
	begin catch
		set @ErrorMes = error_message()
		return 1
	end catch

end
