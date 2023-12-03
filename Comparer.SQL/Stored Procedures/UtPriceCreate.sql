create proc UtPriceCreate
(
	@Sku				int,							--
	@Price				float,							--
	@TypeId				int,							--
	@DocumentId			int,							--
	-- Out-параметры
	@ErrorMes			nvarchar(255) out				-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''
		
	begin try

		-- Создаем запись
		--insert UtPrices
		--	(Sku, Price, TypeId, DocumentId, CreatedDate, ChangedDate)
		--values 
		--	(@Sku, @Price, @TypeId, @DocumentId, getdate(), getdate())

		return 0
	end try
	begin catch		
		set @ErrorMes = 'Ошибка хранимой процедуры UtPriceCreate!'
		return 1
	end catch

end
