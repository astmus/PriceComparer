create proc BQOrderTerminalLastDataClear
(
	@ErrorMes	nvarchar(4000)	out		-- Сообщение об ошибке
)
as
begin
	
	begin try

	set nocount on
	set @ErrorMes = ''

		create table #clearingOrders
		(
			OrderId		uniqueidentifier	not null,		-- Идентификатор заказа
			StatusId	tinyint				not null		-- Идентификатор статуса
			primary key (OrderId)
		)

		-- Получаем идентификаторы заказов в терминальных статусах
		insert #clearingOrders (OrderId, StatusId)
		select
			o.OrderId, o.StatusId
		from 
			BQOrdersLastData o
		where
			o.StatusId in (3, 5, 6, 16)

		print ('Loaded count: ' + cast(@@rowcount as varchar(18)))

		-- Удаляем заказы, которые еще не время очищать
		delete o
		from
			#clearingOrders o
			join
			(
				select 
					h.CLIENTORDER as 'OrderId', h.STATUS as 'StatusId', max(h.STATUSDATE) as 'StatusDate'
				from
					ORDERSSTATUSHISTORY h with (nolock)
					join #clearingOrders o on o.OrderId = h.CLIENTORDER and o.StatusId = h.STATUS
				group by
					h.CLIENTORDER, h.STATUS
			) h on o.OrderId = h.OrderId and o.StatusId = h.StatusId
		where
			(o.StatusId in (5, 16) and h.StatusDate > cast(dateadd(month, -1, getdate()) as date))  -- В статусе получен, утерян через месяц 
			or 
			(o.StatusId in (3, 6) and h.StatusDate > cast(dateadd(week, -1, getdate()) as date))	-- В статусе отменен, возврацен через неделю

		print ('Deleted by time count: ' + cast(@@rowcount as varchar(18)))

		if exists (select 1 from #clearingOrders) begin

			-- Удаляем посление состояния позиций заказов
			delete odi
			from 
				#clearingOrders co
				join BQOrderItemsLastData odi on co.OrderId = odi.OrderId

			print ('Deleted items count: ' + cast(@@rowcount as varchar(18)))

			-- Удаляем последние состояния заказов
			delete od
			from 
				#clearingOrders co
				join BQOrdersLastData od on co.OrderId = od.OrderId

			print ('Deleted orders count: ' + cast(@@rowcount as varchar(18)))

		end

		return 0

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
