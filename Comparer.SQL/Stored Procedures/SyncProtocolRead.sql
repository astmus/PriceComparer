create proc SyncProtocolRead (	
	@SiteId				uniqueidentifier,	-- Идентификатор сайта
	@ApiPoint			nvarchar(255),		-- Ветка API
	@ObjectType			int,				-- Тип объекта синхронизации
	@ObjectId			varchar(50),		-- Идентификатор объекта синхронизации
	@Method				int,				-- Метод
	@Content			text,				-- Содержимое запроса
	@ResponseAnswer		text,				-- Содержимое ответа
	@ResponseCode		int,				-- Код ответа	
	@AuthorId			uniqueidentifier,	-- Автор изменений
	-- Выходные параметры
	@ErrorMes			nvarchar(255) out	-- Сообщение об ошибках
) as
begin

	set @ErrorMes = ''

	begin try

		insert SyncProtocol (SiteId, ApiPoint, ObjectTypeId, ObjectId, MethodId, Content, ResponseAnswer, ResponseCode, AuthorId)
		values (@SiteId, @ApiPoint, @ObjectType, @ObjectId, @Method, @Content, @ResponseAnswer, @ResponseCode, @AuthorId)

		return 0
	end try
	begin catch
		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры SyncProtocolRead!'		
		return 1
	end catch

end
