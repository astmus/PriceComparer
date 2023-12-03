create proc DeliveryServiceGroupsView_v2 
(
	@InnerId				int,			-- Внутренний идентификатор группы
	@OuterId				varchar(50),	-- Внешний идентификатор группы
	@Name					varchar(50),	-- Имя группы
	@CreatedDateFrom		date,			-- Дата создания с
	@CreatedDateTo			date,			-- Дата создания до
	@SentDateFrom			date,			-- Дата сдачи с
	@SentDateTo				date,			-- Дата сдачи до
	@ServiceId				int,			-- Идентификатор ТК
	@TypeId					int,			-- Тип группы
	@CategoryId				int,			-- Категория группы
	@DocsLoaded				bit,			-- Документы загружены
	@OrderPublicNumber		varchar(20),	-- Публичный номер заказа
	@OrderDispatchNumber	varchar(50),		-- Номер отправления
	@StatusId				int = null		-- Статус группы
) as
begin

	-- Если указан идентификатор группы
	if @InnerId is not null begin

		select top 1000
				g.Id as 'InnerId', g.OuterId as 'OuterId', g.Name as 'GroupName', a.Name as 'AccountName',
				g.CreatedDate as 'CreatedDate', g.ServiceId as 'ServiceId', g.StatusId as 'StatusId',
				i.TypeId as 'TypeId', i.CategoryId as 'CategoryId', i.ExpectedDate as 'ExpectedDate',
				i.DocsLoaded as 'DocsLoaded', i.IsSent as 'IsSent', i.SentDate as 'SentDate',				
				s.Name as 'ServiceName', t.Name as 'TypeName', c.Name as 'CategoryName', count(gl.OrderId) as 'OrdersCount'
		from ApiDeliveryServiceGroups g
			join ApiDeliveryServices s on s.Id = g.ServiceId
			left join ApiDeliveryServiceGroupsInfo i on g.Id = i.Id
			left join ApiDeliveryServiceRusPostGroupTypes t on t.Id = i.TypeId
			left join ApiDeliveryServiceRusPostGroupCaregories c on c.Id = i.CategoryId
			left join ApiDeliveryServicesAccounts a on a.Id = g.AccountId
			left join ApiDeliveryServiceGroupOrderLinks gl on gl.GroupId = g.Id
		where g.Id = @InnerId
		group by g.Id, g.OuterId, g.Name, a.Name, g.CreatedDate, g.ServiceId, g.StatusId,
				i.TypeId, i.CategoryId, i.ExpectedDate, i.DocsLoaded, i.IsSent, i.SentDate,				
				s.Name, t.Name, c.Name 

	end else
	-- Если указан внешний идентификатор группы
	if @OuterId is not null begin

		select top 1000
				g.Id as 'InnerId', g.OuterId as 'OuterId', g.Name as 'GroupName', a.Name as 'AccountName',
				g.CreatedDate as 'CreatedDate', g.ServiceId as 'ServiceId', g.StatusId as 'StatusId',
				i.TypeId as 'TypeId', i.CategoryId as 'CategoryId', i.ExpectedDate as 'ExpectedDate',
				i.DocsLoaded as 'DocsLoaded', i.IsSent as 'IsSent', i.SentDate as 'SentDate',				
				s.Name as 'ServiceName', t.Name as 'TypeName', c.Name as 'CategoryName', count(gl.OrderId) as 'OrdersCount'
		from ApiDeliveryServiceGroups g
			join ApiDeliveryServices s on s.Id = g.ServiceId
			left join ApiDeliveryServiceGroupsInfo i on g.Id = i.Id
			left join ApiDeliveryServiceRusPostGroupTypes t on t.Id = i.TypeId
			left join ApiDeliveryServiceRusPostGroupCaregories c on c.Id = i.CategoryId
			left join ApiDeliveryServicesAccounts a on a.Id = g.AccountId
			left join ApiDeliveryServiceGroupOrderLinks gl on gl.GroupId = g.Id
		where g.OuterId = @OuterId
		group by g.Id, g.OuterId, g.Name, a.Name, g.CreatedDate, g.ServiceId, g.StatusId,
				i.TypeId, i.CategoryId, i.ExpectedDate, i.DocsLoaded, i.IsSent, i.SentDate,				
				s.Name, t.Name, c.Name 

	end else
	-- Если указано имя группы
	if @Name is not null begin

		select top 1000
				g.Id as 'InnerId', g.OuterId as 'OuterId', g.Name as 'GroupName', a.Name as 'AccountName',
				g.CreatedDate as 'CreatedDate', g.ServiceId as 'ServiceId', g.StatusId as 'StatusId',
				i.TypeId as 'TypeId', i.CategoryId as 'CategoryId', i.ExpectedDate as 'ExpectedDate',
				i.DocsLoaded as 'DocsLoaded', i.IsSent as 'IsSent', i.SentDate as 'SentDate',				
				s.Name as 'ServiceName', t.Name as 'TypeName', c.Name as 'CategoryName', count(gl.OrderId) as 'OrdersCount'
		from ApiDeliveryServiceGroups g
			join ApiDeliveryServices s on s.Id = g.ServiceId
			left join ApiDeliveryServiceGroupsInfo i on g.Id = i.Id
			left join ApiDeliveryServiceRusPostGroupTypes t on t.Id = i.TypeId
			left join ApiDeliveryServiceRusPostGroupCaregories c on c.Id = i.CategoryId
			left join ApiDeliveryServicesAccounts a on a.Id = g.AccountId
			left join ApiDeliveryServiceGroupOrderLinks gl on gl.GroupId = g.Id
		where g.Name = @Name
		group by g.Id, g.OuterId, g.Name, a.Name, g.CreatedDate, g.ServiceId, g.StatusId,
				i.TypeId, i.CategoryId, i.ExpectedDate, i.DocsLoaded, i.IsSent, i.SentDate,				
				s.Name, t.Name, c.Name 

	end else
	-- Если указан Публичный номер заказа
	if @OrderPublicNumber is not null begin

		select top 1000
				g.Id as 'InnerId', g.OuterId as 'OuterId', g.Name as 'GroupName', a.Name as 'AccountName',
				g.CreatedDate as 'CreatedDate', g.ServiceId as 'ServiceId', g.StatusId as 'StatusId',
				i.TypeId as 'TypeId', i.CategoryId as 'CategoryId', i.ExpectedDate as 'ExpectedDate',
				i.DocsLoaded as 'DocsLoaded', i.IsSent as 'IsSent', i.SentDate as 'SentDate',				
				s.Name as 'ServiceName', t.Name as 'TypeName', c.Name as 'CategoryName', count(gl.OrderId) as 'OrdersCount'
		from ApiDeliveryServiceGroups g
			join ApiDeliveryServices s on s.Id = g.ServiceId
			left join ApiDeliveryServiceGroupsInfo i on g.Id = i.Id
			left join ApiDeliveryServiceRusPostGroupTypes t on t.Id = i.TypeId
			left join ApiDeliveryServiceRusPostGroupCaregories c on c.Id = i.CategoryId
			left join ApiDeliveryServicesAccounts a on a.Id = g.AccountId
			left join ApiDeliveryServiceGroupOrderLinks gl on gl.GroupId = g.Id
		where exists (	select 1 
						from ApiDeliveryServiceGroupOrderLinks l
							join CLIENTORDERS o on l.OrderId = o.ID 
								and case when o.PUBLICNUMBER = '' then cast(o.NUMBER as varchar(50)) else o.PUBLICNUMBER end = @OrderPublicNumber
						where l.GroupId = g.Id
						)
		group by g.Id, g.OuterId, g.Name, a.Name, g.CreatedDate, g.ServiceId, g.StatusId,
				i.TypeId, i.CategoryId, i.ExpectedDate, i.DocsLoaded, i.IsSent, i.SentDate,				
				s.Name, t.Name, c.Name 

	end else
	-- Если указан Номер отправления
	if @OrderDispatchNumber is not null begin

		select top 1000
				g.Id as 'InnerId', g.OuterId as 'OuterId', g.Name as 'GroupName', a.Name as 'AccountName',
				g.CreatedDate as 'CreatedDate', g.ServiceId as 'ServiceId', g.StatusId as 'StatusId',
				i.TypeId as 'TypeId', i.CategoryId as 'CategoryId', i.ExpectedDate as 'ExpectedDate',
				i.DocsLoaded as 'DocsLoaded', i.IsSent as 'IsSent', i.SentDate as 'SentDate',				
				s.Name as 'ServiceName', t.Name as 'TypeName', c.Name as 'CategoryName', count(gl.OrderId) as 'OrdersCount'
		from ApiDeliveryServiceGroups g
			join ApiDeliveryServices s on s.Id = g.ServiceId
			left join ApiDeliveryServiceGroupsInfo i on g.Id = i.Id
			left join ApiDeliveryServiceRusPostGroupTypes t on t.Id = i.TypeId
			left join ApiDeliveryServiceRusPostGroupCaregories c on c.Id = i.CategoryId
			left join ApiDeliveryServicesAccounts a on a.Id = g.AccountId
			left join ApiDeliveryServiceGroupOrderLinks gl on gl.GroupId = g.Id
		where exists (	select 1 
						from ApiDeliveryServiceGroupOrderLinks l
							join CLIENTORDERS o on l.OrderId = o.ID and o.DISPATCHNUMBER = @OrderDispatchNumber
						where l.GroupId = g.Id
						)
		group by g.Id, g.OuterId, g.Name, a.Name, g.CreatedDate, g.ServiceId, g.StatusId,
				i.TypeId, i.CategoryId, i.ExpectedDate, i.DocsLoaded, i.IsSent, i.SentDate,				
				s.Name, t.Name, c.Name 

	end else 
	-- При других заданных параметрах
	begin

		select top 1000
				g.Id as 'InnerId', g.OuterId as 'OuterId', g.Name as 'GroupName', a.Name as 'AccountName',
				g.CreatedDate as 'CreatedDate', g.ServiceId as 'ServiceId', g.StatusId as 'StatusId',
				i.TypeId as 'TypeId', i.CategoryId as 'CategoryId', i.ExpectedDate as 'ExpectedDate',
				i.DocsLoaded as 'DocsLoaded', i.IsSent as 'IsSent', i.SentDate as 'SentDate',				
				s.Name as 'ServiceName', t.Name as 'TypeName', c.Name as 'CategoryName', count(gl.OrderId) as 'OrdersCount'
		from ApiDeliveryServiceGroups g
			join ApiDeliveryServices s on s.Id = g.ServiceId
			left join ApiDeliveryServiceGroupsInfo i on g.Id = i.Id
			left join ApiDeliveryServiceRusPostGroupTypes t on t.Id = i.TypeId
			left join ApiDeliveryServiceRusPostGroupCaregories c on c.Id = i.CategoryId
			left join ApiDeliveryServicesAccounts a on a.Id = g.AccountId
			left join ApiDeliveryServiceGroupOrderLinks gl on gl.GroupId = g.Id
		where 
			(@CreatedDateFrom	is null	or (@CreatedDateFrom	is not null and cast(g.CreatedDate as date) >= @CreatedDateFrom))							and
			(@CreatedDateTo		is null	or (@CreatedDateTo		is not null and cast(g.CreatedDate as date) < @CreatedDateTo))								and
			(@ServiceId			is null	or (@ServiceId			is not null and g.ServiceId = @ServiceId))													and
			(@SentDateFrom		is null	or (@SentDateFrom		is not null and i.SentDate is not null and cast(i.SentDate as date) >= @CreatedDateFrom))	and
			(@SentDateTo		is null	or (@SentDateTo			is not null and i.SentDate is not null and cast(i.SentDate as date) < @SentDateTo))			and			
			(@TypeId			is null	or (@TypeId				is not null and i.TypeId		is not null and i.TypeId = @TypeId))						and
			(@CategoryId		is null	or (@CategoryId			is not null and i.CategoryId	is not null and i.CategoryId = @CategoryId))				and
			(@StatusId			is null	or (@StatusId = 0)  or  (@StatusId			is not null and g.StatusId	is not null and g.StatusId = @StatusId))	and
			(@DocsLoaded		is null	or (@DocsLoaded			is not null and i.DocsLoaded	is not null and i.DocsLoaded = @DocsLoaded))
		group by g.Id, g.OuterId, g.Name, a.Name, g.CreatedDate, g.ServiceId, g.StatusId,
				i.TypeId, i.CategoryId, i.ExpectedDate, i.DocsLoaded, i.IsSent, i.SentDate,				
				s.Name, t.Name, c.Name 
		order by g.CreatedDate desc

	end

end
