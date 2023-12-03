create proc SyncProtocolView
(
	@SiteId				uniqueidentifier,	-- Идентификатор сайта
	@ApiPoint			nvarchar(255),		-- Ветка API
	@ObjectTypeId		int,				-- Тип объекта синхронизации
	@ObjectId			nvarchar(36),		-- Идентификатор объекта синхронизации
	@MethodId			int,				-- Метод
	@Content			nvarchar(100),		-- Содержимое запроса
	@ResponseAnswer		nvarchar(100),		-- Содержимое ответа
	@ResponseCode		int,				-- Код ответа	
	@ResponseCodeGroup	int,				-- Группа кодов, полученные в ответ на запросы
											-- 1 - Успешные запросы
											-- 2 - Запросы с ошибкой в запросе
											-- 3 - Запросы с критической ошибкой сервиса
	@DateFrom			date,				-- Дата с
	@DateTo				date,				-- Дата до
	@AuthorId			uniqueidentifier	-- Автор изменений
) as
begin

	
	select	p.Id, p.SiteId, p.ApiPoint, p.ObjectTypeId, p.ObjectId, p.MethodId, p.ResponseCode, p.AuthorId, p.CreatedDate,
			case when p.Content is null then '' else case when len(p.Content)>155 then substring(p.Content,1,155) else p.Content end end as 'Content',
			case when len(p.ResponseAnswer)>155 then substring(p.ResponseAnswer,1,155) else p.ResponseAnswer end as 'ResponseAnswer',
			u.NAME as 'AuthorName', o.Name as 'ObjectTypeName', s.NAME as 'SiteName', m.Name as 'MethodName'
	from SyncProtocol p 
		join USERS u on u.ID = p.AuthorId
		join ObjectTypes o on o.Id = p.ObjectTypeId
		join HttpMethods m on m.Id = p.MethodId
		join SITES s on s.ID = p.SiteId
	where p.CreatedDate >= @DateFrom and p.CreatedDate < dateadd(dd, 1, @DateTo)
		and (@SiteId is null or (@SiteId is not null and p.SiteId = @SiteId))
		and (@ObjectId is null or (@ObjectId is not null and p.ObjectId = @ObjectId))
		and (@ObjectTypeId is null or (@ObjectTypeId is not null and p.ObjectTypeId = @ObjectTypeId))
		and (@MethodId is null or (@MethodId is not null and p.MethodId = @MethodId))
		and (@AuthorId is null or (@AuthorId is not null and p.AuthorId = @AuthorId))
		and (@ResponseCode is null or (@ResponseCode is not null and p.ResponseCode = @ResponseCode))
		and (@ResponseCodeGroup is null or (@ResponseCodeGroup is not null
										and p.ResponseCode >= case 
																when @ResponseCodeGroup = 1 then 200
																when @ResponseCodeGroup = 2 then 300
																when @ResponseCodeGroup = 3 then 500
															end
										and p.ResponseCode < case 
																when @ResponseCodeGroup = 1 then 300
																when @ResponseCodeGroup = 2 then 500
																when @ResponseCodeGroup = 3 then 1000
															end
															))
		and (@ApiPoint is null or (@ApiPoint is not null and p.ApiPoint like '%'+@ApiPoint+'%'))
		and (@Content is null or (@Content is not null and p.Content like '%'+@Content+'%'))
		and (@ResponseAnswer is null or (@ResponseAnswer is not null and p.ResponseAnswer like '%'+@ResponseAnswer+'%'))
	order by p.CreatedDate desc

end
