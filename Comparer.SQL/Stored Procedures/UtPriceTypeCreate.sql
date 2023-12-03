create proc UtPriceTypeCreate
(
	@Id			int,		-- ИД УТ
	@Name		varchar(64),			-- Название
	-- Out-параметры
	@ErrorMes	nvarchar(255) out		-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''
		
	begin try

		-- Создаем запись
		insert UtPriceTypes
			(Id, Name)
		values 
			(@Id, @Name)

		return 0
	end try
	begin catch		
		set @ErrorMes = 'Ошибка хранимой процедуры UtPriceTypeCreate!'
		return 1
	end catch

end
