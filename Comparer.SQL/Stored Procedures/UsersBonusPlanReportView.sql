create proc UsersBonusPlanReportView
(	
	@BeginDate			date,
	@EndDate			date
) as
begin
	-- Таблица полученных заказов
	create table #ReceivedOrders
	(
		OrderId			uniqueidentifier		not null,
		UserId			uniqueidentifier		not null,
		OrderSum		float					not null,
		PublicNumber	varchar(20)				not null

		primary key (OrderId, UserId)
	)

	-- Таблица менеджеров КЦ
	create table #Users
	(
		UserId		uniqueidentifier	not null,
		FIO			varchar (100)		not null

		primary key (UserId)
	)

	-- Заполнение таблицы полученных заказов
	insert into #ReceivedOrders (OrderId, UserId, OrderSum, PublicNumber)
	select
		distinct o.ID, o.CREATORID, o.FROZENSUM - o.DELIVERY - o.FEE, o.PUBLICNUMBER
	from 
		ORDERSSTATUSHISTORY h
		join CLIENTORDERS o on o.ID = h.CLIENTORDER
		join USERS u on u.ID = o.CREATORID
		join CLIENTS c on c.ID = o.CLIENTID
	where 
		cast(h.STATUSDATE as date) >= @BeginDate
		and cast(h.STATUSDATE as date) <= @EndDate
		and h.STATUS = 5
		and o.STATUS = 5
		and u.DepartmentId = 7
		and u.RoleId not in (21, 49, 19)
		and o.KIND = 1
		and c.IsEmployee = 0
	
	-- Заполнение таблицы менеджеров КЦ
	insert into #Users
	select
		ID,
		LastName + ' ' + FirstName
	from
		USERS 
	where 
		DepartmentId = 7
		and RoleId not in (21, 49, 19) 
		and Status = 1
	select
		UserId	as	'UserId',
		FIO		as  'FIO'
	from
		#Users

	select 
		OrderId			as 'OrderId',
		UserId			as 'UserId',
		OrderSum		as 'OrderSum',
		PublicNumber	as 'PublicNumber'
	from 
		#ReceivedOrders


end
