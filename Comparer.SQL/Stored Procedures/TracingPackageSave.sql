create proc TracingPackageSave
(
	@SourceService		varchar(128),		-- Сервис-источник
	@Operation			varchar(128),		-- Операция
	@EntityTypeId		int,				-- Идентификатор типа сущности
	@EntityId			varchar(36),		-- Идентификатор сущности
	@ErrorMes			nvarchar(4000) out	-- Ошибка выполнения запроса
)
as
begin

	set nocount on
	set @ErrorMes = ''
		
	begin try
		
		-- Создаем запись в таблице пакетов
		insert TracingPackages (SourceService, Operation, EntityTypeId, EntityId) 
		values (@SourceService, @Operation, @EntityTypeId, @EntityId)

		declare
			@packageId	int	= @@identity

		-- Вставляем записи троссировки
		insert TracingPackageItems 
		(
			PackageId, RowNo,
			RequestMethod, RequestQuery, RequestBody, RequestStart, RequestEnd,
			ResponseCode, ResponseBody, ResponseError
		)
		select
			@packageId, RowNo,
			RequestMethod, RequestQuery, RequestBody, RequestStart, RequestEnd,
			ResponseCode, ResponseBody, ResponseError
		from
			#Items

		return 0

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
