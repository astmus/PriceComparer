create proc DeliveryServiceOrdersView_v7
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
	@GroupId			int,
	@SiteId				uniqueidentifier = null,	-- Внутренний идентификатор сайта
	@ProblemInTK		tinyint = null				-- Проблемы с заказом в ТК
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
	-- поиск по нескольким номерам
	if (select count(1)  from #tmp_PublicNumbers) > 0
	begin
		insert into #tempIds
			select o.Id
			from CLIENTORDERS o 
			join #tmp_PublicNumbers n on n.PublicNumber = o.PublicNumber
	end else
	-- Если поиск по публичному номеру заказа
	if @PublicNumber is not null begin

		insert into #tempIds
			select o.Id
			from CLIENTORDERS o 
				 --left join ApiDeliveryServiceOrders do on do.InnerId = o.ID
			where (PublicNumber = @PublicNumber  or PublicNumber like ('___-' + @PublicNumber) or PublicNumber = '' and convert(varchar(100), Number) = @PublicNumber ) and
				  (@SiteId is null or (@SiteId is not null and o.SiteId = @SiteId)) 


	end else
	-- Если поиск по трек-номерам
	if (select count(1)  from #tmp_DispatchNumbers) > 0
	begin
		insert into #tempIds
			select o.InnerId
			from ApiDeliveryServiceOrders o 
			join #tmp_DispatchNumbers n on n.DispatchNumber = o.DispatchNumber
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

	end 
	else begin

		insert into #tempIds
			select
				o.ID as 'InnerId'
			from ApiDeliveryServiceOrders do
				join CLIENTORDERS o on o.ID = do.InnerId		
				left join ApiDeliveryServiceOrderStatuses st on st.Id = do.StatusId
				join DELIVERYTYPES dt on dt.ID = o.DELIVERYKIND
				join PaymentTypes pt on pt.ID = o.PAYMENTKIND
				join CLIENTORDERSTATUSES ist on ist.ID = o.STATUS
				left join SITES s on s.ID = o.SITEID
				left join ApiDeliveryServiceGroupOrderLinks og on o.ID = og.OrderId
				left join ApiDeliveryServiceGroups g on og.GroupId = g.Id
				left join ClientOrdersAdditionalParams op on op.OrderId = o.ID
			where
				(@ServiceId is null			or (@ServiceId is not null			and do.ServiceId = @ServiceId)) and
				(@StatusId is null			or (@StatusId is not null			and do.StatusId = @StatusId)) and
				(@InnerStatusId is null		or (@InnerStatusId is not null		and ((@InnerStatusId <> 15 and ist.ID = @InnerStatusId) or (@InnerStatusId = 15 and (ist.ID in (3, 15)))))) and
				(@PaidState is null			or (@PaidState is not null			and ((@PaidState = 1 and o.PAIDSUM >= o.FROZENSUM) or (@PaidState = 2 and o.PAIDSUM < o.FROZENSUM)))) and
				(@CreatedDateFrom is null	or (@CreatedDateFrom is not null	and cast(do.CreatedDate as date) >= @CreatedDateFrom)) and
				(@CreatedDateTo is null		or (@CreatedDateTo is not null		and cast(do.CreatedDate as date) < @CreatedDateTo)) and
				(@NoGroup is null			or (@NoGroup is not null			and @NoGroup = 1 and not exists(select 1 from ApiDeliveryServiceGroupOrderLinks l where l.OrderId = do.InnerId))) and
				(@SiteId is null			or (@SiteId is not null				and o.SiteId = @SiteId)) and
				(@ProblemInTK is null		or (@ProblemInTK is not null		and (op.ProblemInTK = @ProblemInTK or @ProblemInTK = 0 and op.ProblemInTK is null)))


	end
	
	select 
		o.ID as 'InnerId',
		do.OuterId as 'OuterId',
		isnull(cds.DeliveryServiceId, do.ServiceId) as 'ServiceId',
		ds.Name as 'ServiceName',
		do.AccountId,
		a.Name as 'AccountName',
		isnull(oi.IKNId,do.IKNId) as 'IKNId',
		ikn.Name as 'IKNName',
		do.CreatedDate as 'OuterCreatedDate',
		do.StatusId as 'OuterStatusId',
		isnull(st.Name, '?') as 'OuterStatusName',
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
		IIF(o.paymentkind in (2, 4, 5, 8, 10, 12, 13, 19, 20), cast(1 as bit), cast(0 as bit)) as 'IsPrepaid',
		pt.TITLE as 'PaymentKindName',
		o.SITEID as 'SiteId',
		isnull(s.NAME,'') as 'SiteName',
		g.Id as 'GroupId',
		g.Name as 'GroupName',
		ISNULL(oi.LabelDowloadCount, 0) AS 'LabelDowloadCount',
		o.PAIDSUM as 'PaidSum',
		o.FROZENSUM as 'Sum',
		co.ZIPCODE as 'Zip',
		isnull(cnt.NAME,'') as 'Country',
		co.REGION as 'Region',
		co.DISTRICT as 'District',
		co.LOCALITY as 'Locality',
		co.URBANAREA as 'Area',
		co.CITY as 'City', 
		co.STREET as 'Street', 
		case when co.HOUSE = '' then '' else co.HOUSE_TYPE + ' ' + co.HOUSE end as 'House',
		case when co.BLOCK = '' then '' else co.BLOCK_TYPE + ' ' + co.BLOCK end as 'Block',
		case when co.FLAT = '' then '' else co.FLAT_TYPE + ' ' + co.FLAT end as 'Flat',
		op.ProblemInTK as 'ProblemInTK',
	    --iif(w.ReturnedOrderId is not null and w.DocSource = 2 and o.STATUS <> 6, cast(1 as bit), cast(0 as bit)) 
		IIF(o.[status] <> 6 AND Exists (select 1 from WmsReceiptDocuments where ReturnedOrderId = o.ID AND DocSource = 2), cast(1 as bit), cast(0 as bit))
			as 'PartialReturned',
		o.SERVICECOMMENT as 'Comment',
		sh.STATUSDATE as 'SentDate',
		(case when isnull(co.FIRSTNAME, '') = '' and isnull(co.LASTNAME, '') = ''
			then c.Name + ' ' + c.FatherName + ' ' + c.LastName
			else co.FIRSTNAME + ' ' + co.MIDDLENAME + ' ' + co.LASTNAME end) as 'ClientFullName',
		do.StatusDate as 'OuterStatusDate',
		do.StatusDescription	as 'OuterStatusDescription',
		oi.CompensationNumber as 'CompensationNumber',
		oi.CompensationDate as 'CompensationDate'
	FROM
		#tempIds t 
			left join ApiDeliveryServiceOrders do ON t.InnerId = do.InnerId
			join CLIENTORDERS o on o.ID = t.InnerId
			left join ClientOrdersDelivery cds on cds.orderId = o.Id
			left join ApiDeliveryServices ds ON isnull(cds.DeliveryServiceID, do.ServiceId) = ds.Id
			left join ApiDeliveryServiceOrderStatuses st on st.Id = do.StatusId
			left join DELIVERYTYPES dt on dt.ID = o.DELIVERYKIND
			left join PaymentTypes pt on pt.ID = o.PAYMENTKIND
			left join CLIENTORDERSTATUSES ist on ist.ID = o.STATUS
			left join ApiDeliveryServicesAccounts a on a.Id = do.AccountId
			left join SITES s on s.ID = o.SITEID
			left join ApiDeliveryServiceGroupOrderLinks og on o.ID = og.OrderId
			left join ApiDeliveryServiceGroups g on og.GroupId = g.Id
			left join ApiDeliveryServiceOrdersInfo oi ON do.InnerId = oi.InnerId
			left join CLIENTORDERADDRESSES co on o.ID = co.CLIENTORDERID
			left join COUNTRIES cnt on cnt.ID = co.COUNTRYID
			left join ApiDeliveryServicesIKNs ikn on isnull(oi.IKNId,do.IKNId) = ikn.Id
			left join ClientOrdersAdditionalParams op on op.OrderId = o.ID
			--left join WmsReceiptDocuments w on o.Id = w.ReturnedOrderId 
			left join Clients c on o.CLIENTID = c.ID
			left join 
			(
				select
					CLIENTORDER, Max(StatusDate) as 'STATUSDATE'
				from
					#tempIds t
					join ORDERSSTATUSHISTORY sh on sh.CLIENTORDER = t.InnerId
				where
					Status in (9, 12, 13)
				group by
					CLIENTORDER
			) sh on sh.CLIENTORDER = t.InnerId
	/*order by
		case
			when @InnerStatusId = 15
				then iif (o.STATUS = 3, 0, o.STATUS)
			else
				do.CreatedDate
		end*/

end
