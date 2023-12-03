create proc UsedeskUserInfoView as
begin

	
	create table #clients
	(
		Id			uniqueidentifier		not null,
		Phone		varchar(17)				not null,
		Email		varchar(50)				not null,
		[Name]		varchar(255)			not null,
		RowNo		int						not null
		primary key (Id, RowNo)
	)

	-- 1. Поиск клиента по телефону
	if exists (select 1 from #phones) begin

		insert #clients (Id, Email, Phone, [Name], RowNo)
		select 
			c.ID, 
			c.EMAIL, 
			isnull(c.MOBILEPHONE, '') as 'Phone',
			rtrim(c.[NAME] + ' ' + c.LASTNAME)	as 'Name',
			row_number() over (order by c.CREATEDATE) as 'RowNo'
		from
			CLIENTS c with (nolock)
			--join #phones p on c.MOBILEPHONE like '%' + p.Number
			join #phones p on right(c.MOBILEPHONE, 10) = right(p.Number, 10)
		where
			c.SHOWCASEUSERPOINTOFSALE = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'
			and len(c.MOBILEPHONE) >= 10

	end

	-- Если предыдущий поиск не дал эффекта
	if not exists (select 1 from #clients) begin

		-- 2. Поиск клиента по Email
		insert #clients (Id, Email, Phone, [Name], RowNo)
		select 
			c.ID, 
			c.EMAIL, 
			isnull(c.MOBILEPHONE, '') as 'Phone',
			rtrim(c.[NAME] + ' ' + c.LASTNAME)	as 'Name',
			row_number() over (order by c.CREATEDATE) as 'RowNo'
		from
			CLIENTS c with (nolock)
			join #emails e on c.EMAIL = e.Email
		where
			c.SHOWCASEUSERPOINTOFSALE = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'

	end
	
	-- Если клиент найден
	if exists (select 1 from #clients) begin

		declare
			@hasDoubles		bit					= 0,
			@Id				uniqueidentifier	= null

		-- Проверяем, найдено ли несколько аккаунтов
		if (select count(1) from #clients) > 1
			set @hasDoubles = 1

		select @Id = Id from #clients where RowNo = 1

		-- 3. Заказы пользователя
		create table #orders
		(
			Id						uniqueidentifier	not null,
			ClientId				uniqueidentifier	not null,
			PublicNumber			varchar(20)			not null,
			CreatedDate				datetime			not null,
			TotalSum				float				not null,
			DispatchNumber			nvarchar(50)		not null,
			DeliveryKind			int					not null,
			StatusId				int					not null,
			RowNo					int					not null,
			primary key (RowNo)
		)

		insert #orders (Id, CLientId, PublicNumber, CreatedDate, TotalSum, DispatchNumber, DeliveryKind, StatusId, RowNo)
		select 
			o.ID, o.CLIENTID, o.PUBLICNUMBER, o.[DATE], o.FROZENSUM, o.DISPATCHNUMBER, o.DELIVERYKIND, o.[STATUS], 
			row_number() over (order by o.DATE desc) as 'RowNo'
		from
			CLIENTORDERS o with (nolock)
		where
			o.CLIENTID = @Id

		-- 4. Вывод результатов
		select
			-- Общая информация о клиенте
			c.Id							as 'Id',
			c.[Name]						as 'Name',
			c.Phone							as 'Phone',
			c.Email							as 'Email',
			-- Сводная информация по заказам
			isnull(t.OrdersCount, 0)		as 'OrdersCount',
			isnull(t.TotalSum, 0)			as 'OrdersTotalSum',
			-- Информация о последнем заказе
			l.PublicNumber					as 'LastOrderPublicNumber',
			l.CreatedDate					as 'LastOrderCreatedDate',
			l.DispatchNumber				as 'LastOrderDispatchNumber',
			l.DeliveryKind					as 'LastOrderDeliveryMethod',
			l.DeliveryType					as 'LastOrderTKDeliveryType',
			l.StatusName					as 'LastOrderStatus',
			l.TotalSum						as 'LastOrderTotalSum',
			h.StatusDate					as 'LastOrderDeliveryDate',
			-- Доп инфо
			@hasDoubles						as 'SeveralAccountsExist'
		from
			#clients c
			left join
			(
				select 
					o.CLientId				as 'CLientId',
					count(1)				as 'OrdersCount',
					sum(o.TotalSum)			as 'TotalSum'
				from
					#orders o
				group by
					o.CLientId
			) t on t.CLientId = c.Id
			left join
			(
				select 
					o.CLientId				as 'CLientId',
					o.TotalSum				as 'TotalSum',
					o.DispatchNumber		as 'DispatchNumber',
					dt.TITLE				as 'DeliveryKind',
					cod.DeliveryServiceId	as 'DeliveryType',
					o.PublicNumber			as 'PublicNumber',
					o.CreatedDate			as 'CreatedDate',
					isnull(st.[NAME], '?')	as 'StatusName'
				from
					#orders o
					left join CLIENTORDERSTATUSES st with (nolock) on st.ID = o.StatusId		
					left join DELIVERYTYPES dt on dt.ID = o.DELIVERYKIND
					left join ClientOrdersDelivery cod on o.Id = cod.OrderId
				where
					o.RowNo = 1
			) l on l.CLientId = c.Id
			left join
			(
				select 
					o.ClientId			as 'ClientId',
					max(h.STATUSDATE)	as 'StatusDate'
				from 
					#orders o
					join ORDERSSTATUSHISTORY h with (nolock) on h.CLIENTORDER = o.Id
				where
					o.RowNo = 1
				group by
					o.ClientId
			) h on h.ClientId = c.Id
		order by LastOrderCreatedDate desc
	end
	
end
