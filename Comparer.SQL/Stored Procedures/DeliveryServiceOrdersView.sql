create procedure DeliveryServiceOrdersView
(
	@InnerId			uniqueidentifier,			-- Внутренний идентификатор заказа
	@OuterId			varchar(50),				-- Идентификатор заказа в ЛК ТК
	@PublicNumber		varchar(20),				-- Публичный номер заказа
	@ServiceId			int,						-- Идентификатор ТК
	@StatusId			int,						-- Идентификатор статуса ТК
	@PaidState			int,						-- Состояние оплаты
													-- 1 - Оплаченные
													-- 2 - Наложенный платеж
	@CreatedDateFrom	date,						-- Дата создания заказа в ЛК ТК с
	@CreatedDateTo		date,						-- Дата создания заказа в ЛК ТК до
	@NoGroup			bit,						-- Не распределенные по группам
	@InnerStatusId		int,
	@GroupId			int
) as
begin

	create table #tempIds(	
		InnerId		uniqueidentifier	not null,
		primary key(InnerId)
	)

	-- Если поиск по внутреннему идентификатору заказа
	if @InnerId is not null begin

		insert into #tempIds
			select @InnerId

	end else
	-- Если поиск по внешнему идентификатору заказа
	if @OuterId is not null begin

		insert into #tempIds
			select InnerId FROM ApiDeliveryServiceOrders where OuterId = @OuterId

	end else
	-- Если поиск по публичному номеру заказа
	if @PublicNumber is not null begin

		insert into #tempIds
			select do.InnerId
			from ApiDeliveryServiceOrders do
				 join CLIENTORDERS o on do.InnerId = o.ID
			where o.PUBLICNUMBER = @PublicNumber

	end else
	-- поиск по номеру группы
	if @GroupId is not null begin

		insert into #tempIds
			select do.InnerId 
			from ApiDeliveryServiceOrders do
				 join CLIENTORDERS o ON do.InnerId = o.ID
				 left join ApiDeliveryServiceGroupOrderLinks og ON o.ID = og.OrderId
				 left join ApiDeliveryServiceGroups g ON og.GroupId = g.Id
			where g.Id = @GroupId

	end else begin

		insert into #tempIds
			select
				o.ID as 'InnerId'
			from ApiDeliveryServiceOrders do
				join CLIENTORDERS o on o.ID = do.InnerId		
				join ApiDeliveryServiceOrderStatuses st on st.Id = do.StatusId
				join DELIVERYTYPES dt on dt.ID = o.DELIVERYKIND
				join PaymentTypes pt on pt.ID = o.PAYMENTKIND
				join CLIENTORDERSTATUSES ist on ist.ID = o.STATUS
				left join SITES s on s.ID = o.SITEID
				left join ApiDeliveryServiceGroupOrderLinks og on o.ID = og.OrderId
				left join ApiDeliveryServiceGroups g on og.GroupId = g.Id
			where
				(@ServiceId is null			or (@ServiceId is not null			and do.ServiceId = @ServiceId)) and
				(@StatusId is null			or (@StatusId is not null			and do.StatusId = @StatusId)) and
				(@PaidState is null			or (@PaidState is not null			and ((@PaidState = 1 and o.PAIDSUM >= o.FROZENSUM) or (@PaidState = 2 and o.PAIDSUM < o.FROZENSUM)))) and
				(@CreatedDateFrom is null	or (@CreatedDateFrom is not null	and cast(do.CreatedDate as date) >= @CreatedDateFrom)) and
				(@CreatedDateTo is null		or (@CreatedDateTo is not null		and cast(do.CreatedDate as date) < @CreatedDateTo)) and
				(@NoGroup is null			or (@NoGroup is not null			and @NoGroup = 1 and not exists(select 1 from ApiDeliveryServiceGroupOrderLinks l where l.OrderId = do.InnerId)))

	end

	select top 10000
		o.ID as 'InnerId',
		do.OuterId as 'OuterId',
		do.ServiceId as 'ServiceId',
		ds.Name as 'ServiceName',
		do.AccountId,
		a.Name as 'AccountName',
		isnull(oi.IKNId,do.IKNId) as 'IKNId',
		do.CreatedDate as 'OuterCreatedDate',
		do.StatusId as 'OuterStatusId',
		st.Name as 'OuterStatusName',
		o.DATE as 'InnerCreatedDate',
		o.WEIGHT as 'Weight',
		case when o.PUBLICNUMBER = '' then cast(o.NUMBER as varchar(20)) else o.PUBLICNUMBER end as 'PublicNumber', 
		o.DISPATCHNUMBER as 'DispatchNumber',
		o.PACKED as 'Packed',
		o.STATUS as 'InnerStatusId',
		ist.NAME as 'InnerStatusName',
		o.DELIVERYKIND as 'DeliveryKindId',
		dt.NAME as 'DeliveryKindName',
		o.PAYMENTKIND as 'PaymentKindId',
		IIF(o.paymentkind in (2, 4, 5, 8, 10, 12, 13), cast(1 as bit), cast(0 as bit)) as 'IsPrepaid',
		pt.TITLE as 'PaymentKindName',
		o.SITEID as 'SiteId',
		isnull(s.NAME,'') as 'SiteName',
		g.Id as 'GroupId',
		g.Name as 'GroupName',
		ISNULL(oi.LabelDowloadCount, 0) AS 'LabelDowloadCount',
		o.PAIDSUM as 'PaidSum',
		o.FROZENSUM as 'Sum',
		co.REGION as 'Region',
		co.URBANAREA as 'Area',
		co.DISTRICT as 'District'

	from #tempIds t 
		join ApiDeliveryServiceOrders do ON t.InnerId = do.InnerId
		join CLIENTORDERS o on o.ID = do.InnerId
		join ApiDeliveryServices ds ON do.ServiceId = ds.Id
		join ApiDeliveryServiceOrderStatuses st on st.Id = do.StatusId
		join DELIVERYTYPES dt on dt.ID = o.DELIVERYKIND
		join PaymentTypes pt on pt.ID = o.PAYMENTKIND
		join CLIENTORDERSTATUSES ist on ist.ID = o.STATUS
		join ApiDeliveryServicesAccounts a on a.Id = do.AccountId
		join CLIENTORDERADDRESSES co on o.ID = co.CLIENTORDERID
		left join SITES s on s.ID = o.SITEID
		left join ApiDeliveryServiceGroupOrderLinks og on o.ID = og.OrderId
		left join ApiDeliveryServiceGroups g on og.GroupId = g.Id
		left join ApiDeliveryServiceOrdersInfo oi ON do.InnerId = oi.InnerId			

end
