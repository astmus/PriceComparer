create proc UsersGroupPlanReportView
(	
	@BeginDate			date,
	@EndDate			date,
	@OrdersCount		int out,
	@SlovedOrdersCount	int out
) as
begin
	-- Задачи
	create table #tasks
	(
		OrderId					uniqueidentifier		not null,	
		TaskSolverId			uniqueidentifier		not null,
		OrderStatus				int						not null,
		OrderSum				float					not null,
		ThreadId				int						not null,
		ThreadSolverId			uniqueidentifier			null,
		ThreadResultId			int							null,
		ThreadSolvedResultId	int							null
	)

	-- Количество задач
	create table #tasksForCount
	(
		OrderId					uniqueidentifier		not null,
		ThreadSolvedResultId	int							null,
		TaskCategoryId			int						not null
	)

	-- Отчет
	create table #report
	(
		UserID						uniqueidentifier	not null,
		OrdersCount					int					not null,		-- Общее кол-во решенных заказов
		OrdersSum					float				not null,		-- 

		primary key(UserID)
	)

	-- Таблица заказов
	create table #orders
	(
		Id					uniqueidentifier		not null,
		StatusId			int						not null,
		ProductsSum			float					not null,
		primary key (Id)
	)

	-- Таблица для удаления ответственных, 
	-- которые решили по одному и тому же заказу несколько проблем 
	create table #threadsForRemove
	(
		ThreadId	int			not null,
		primary key (ThreadId)
	)

	-- Таблица решенных задач
	create table #solvedOrders
	(
		SolverId		uniqueidentifier	not null,
		OrderId			uniqueidentifier	not null,
		OrderSum		float				not null
		primary key (OrderId, SolverId)
	)

	-- Заполнение таблицы для подсчета задач
	insert #tasksForCount 
	(
		OrderId, ThreadSolvedResultId, TaskCategoryId
	)
	select 
		t.OrderId, th.SolveResultId, t.CategoryId
	from 
		OrderProblemTaskThreads th
		join OrderProblemTasks t on t.Id = th.TaskId
		join CLIENTORDERS o on o.ID = t.OrderId
		join Users kc on kc.ID = t.AuthorId
		left join Users u on u.ID = th.SolverId
		left join Users uth on uth.ID = th.UserId
	where
		o.KIND in (1, 2)
		and t.CategoryId in (1,2)
		and o.STATUS not in (7,8)
		and t.LevelId = 2
		and
		(
			(
				th.SolverId is not null
				and th.StatusId = 3
				and th.SolveResultId in (1, 2)
				and u.DepartmentId = 7
				and cast(th.SolvedDate as date) >= @BeginDate
				and cast(th.SolvedDate as date) <= @EndDate	
			)
			or
			(
				th.SolverId is null
				and t.StatusId = 3
				and t.SolveResultId in (1, 2)
				and t.SolverId in ('310FAFF6-9306-44EA-AEA5-44E43C0D5F39', '4966E5F3-3A47-433D-872C-E525BE1DC096')	-- ShopBaseUser  ShopBaseBot
				and
				(
					th.DepartmentId = 7
					or
					uth.DepartmentId = 7
				)
				and cast(t.SolvedDate as date) >= @BeginDate
				and cast(t.SolvedDate as date) <= @EndDate	
			)
		)	
		and kc.DepartmentId <> 7

	-- Заполянем таблицу заданий (по SolvedDate)
	--insert #tasks
	--(
	--	OrderId,  TaskSolverId, ThreadSolverId, OrderStatus, OrderSum, ThreadResultId, ThreadId, ThreadSolvedResultId
	--)
	--select 
	--	t.OrderId, 
	--	t.SolverId, 
	--	th.SolverId,
	--	o.STATUS,
	--	o.FROZENSUM - isnull(o.DELIVERY, 0.0) - isnull(o.FEE, 0.0),
	--	th.SolveResultId, 
	--	th.Id,
	--	th.SolveResultId
	--from 
	--	OrderProblemTaskThreads th
	--	join OrderProblemTasks t on t.Id = th.TaskId
	--	join CLIENTORDERS o on o.ID = t.OrderId
	--	join Users kc on kc.ID = t.AuthorId
	--	left join Users u on u.ID = th.SolverId
	--	left join Users uth on uth.ID = th.UserId
	--where
	--	o.KIND in (1, 2)
	--	and t.CategoryId in (1,2)
	--	and o.STATUS = 5
	--	and t.LevelId = 2
	--	and
	--	(
	--		(
	--			th.SolverId is not null
	--			and th.StatusId = 3
	--			and
	--			(
	--				th.SolveResultId = 1
	--				or
	--				(
	--					t.CategoryId = 2
	--					and
	--					th.SolveResultId = 2
	--				)
	--			)
	--			and u.DepartmentId = 7
	--			and cast(th.SolvedDate as date) >= @BeginDate
	--			and cast(th.SolvedDate as date) <= @EndDate	
	--		)
	--		or
	--		(
	--			th.SolverId is null
	--			and t.StatusId = 3
	--			and 
	--			(
	--				t.SolveResultId = 1
	--				or
	--				(
	--					t.CategoryId = 2
	--					and
	--					t.SolveResultId = 2
	--				)
	--			)
	--			and t.SolverId in ('310FAFF6-9306-44EA-AEA5-44E43C0D5F39', '4966E5F3-3A47-433D-872C-E525BE1DC096')	-- ShopBaseUser  ShopBaseBot
	--			and
	--			(
	--				th.DepartmentId = 7
	--				or
	--				uth.DepartmentId = 7
	--			)
	--			and cast(t.SolvedDate as date) >= @BeginDate
	--			and cast(t.SolvedDate as date) <= @EndDate	
	--		)
	--	)	
	--	and kc.DepartmentId <> 7

	insert #tasks
	(
		OrderId,  TaskSolverId, ThreadSolverId, OrderStatus, OrderSum, ThreadResultId, ThreadId, ThreadSolvedResultId
	)
	select 
		t.OrderId, 
		t.SolverId, 
		th.SolverId,
		o.STATUS,
		o.FROZENSUM - isnull(o.DELIVERY, 0.0) - isnull(o.FEE, 0.0),
		th.SolveResultId, 
		th.Id,
		th.SolveResultId
	from 
		CLIENTORDERS o 
		join OrderProblemTasks t on o.ID = t.OrderId
		join
		(
			select 
				h.CLIENTORDER		as 'OrderId',
				min(h.STATUSDATE)	as 'MaxStatusDate'
			from
				ORDERSSTATUSHISTORY h
			where
				h.STATUS = 5
				and cast(h.STATUSDATE as date) >= @BeginDate
				and cast(h.STATUSDATE as date) <= @EndDate
			group by
				h.CLIENTORDER
		) st on st.OrderId = t.OrderId
		join OrderProblemTaskThreads th on t.Id = th.TaskId
		join Users kc on kc.ID = t.AuthorId
		left join Users u on u.ID = th.SolverId		
	where
		o.KIND in (1, 2)
		and o.[STATUS] = 5
		and t.CategoryId in (1, 2)
		and t.LevelId = 2
		and
		(
			(
				th.SolverId is not null
				and th.StatusId = 3
				and
				(
					th.SolveResultId = 1
					or
					(
						t.CategoryId = 2
						and
						th.SolveResultId = 2
					)
				)
				and u.DepartmentId = 7
			)
			or
			(
				th.SolverId is null
				and t.StatusId = 3
				and 
				(
					t.SolveResultId = 1
					or
					(
						t.CategoryId = 2
						and
						t.SolveResultId = 2
					)
				)
				and t.SolverId in ('310FAFF6-9306-44EA-AEA5-44E43C0D5F39', '4966E5F3-3A47-433D-872C-E525BE1DC096')	-- ShopBaseUser или ShopBaseBot
				and
				(
					th.DepartmentId = 7					
				)				
			)
		)	
		and kc.DepartmentId <> 7
		

	-- Заказы
	insert #orders (Id, StatusId, ProductsSum)
	select
		o.Id, 
		o.[Status], 
		o.FROZENSUM - isnull(o.DELIVERY, 0.0) - isnull(o.FEE, 0.0)
	from 
	(
		select distinct OrderId from #tasks
	) t
		join ClientOrders o on o.ID = t.OrderId
		join CLIENTORDERSTATUSES st on st.Id = o.[Status]

	---- Заполняем таблицу для удаления ответственных
	insert #threadsForRemove (ThreadId)
	select 
		t.ThreadId
	from
	(
		select
			t.OrderId, t.ThreadSolverId, t.ThreadId,
			row_number() over
			(
				partition by 
					t.OrderId, t.ThreadSolverId 
				order by 
					case
						when o.StatusId in (3, 6)
							then iif(t.ThreadSolvedResultId = 1, 1, 99)
						else
							iif(t.ThreadSolvedResultId = 1, 99, 1)
					end desc
			) as RowNo
		from
			#tasks t
				join #orders o on o.Id = t.OrderId
		where
			t.ThreadSolverId is not null			
	) t
	where
		t.RowNo > 1

	-- Удаляем повторяющихся ответственных
	delete t
	from
		#tasks t
			join #threadsForRemove r on t.ThreadId = r.ThreadId
	
	-- Заполняем таблицу решенных задач
	insert #solvedOrders (SolverId, OrderId, OrderSum)
	select distinct
		t.ThreadSolverId,
		t.OrderId,
		t.OrderSum
	from 
		#tasks t
		join USERS u on u.ID = t.ThreadSolverId
	where 
		t.OrderStatus = 5

	-- Вспомогательная таблица совместно решенных задач
	create table #dopCollectiveOrders
	(
		OrderId			uniqueidentifier		not null,
		SolverId		uniqueidentifier		not null,
		RowNo			int						not null,
		primary key (OrderId, SolverId)
	)

	-- Заполянем вспомогательную таблицу совместно решенных задач
	insert #dopCollectiveOrders (OrderId, SolverId, RowNo)
	select
		t.OrderId, t.ThreadSolverId,
		row_number() over(partition by t.OrderId order by t.ThreadSolverId) as RowNo
	from
	(
		select distinct 
			 t.OrderId, 
			 t.ThreadSolverId
		from
			#tasks t
			join #orders o on o.Id = t.OrderId
		where
			o.StatusId = 5
			and t.TaskSolverId is not null
			and t.ThreadSolverId is not null
			and t.ThreadResultId = 1
	) t

	-- Совместно решенные задачи
	create table #collectiveOrders
	(
		OrderId			uniqueidentifier		not null,
		SolverId		uniqueidentifier		not null,
		OrderSum		float					not null default(0),
		RowNo			int						not null,
		primary key (OrderId, SolverId)
	)

	--Заполняем таблицу совместно решенных задач
	insert #collectiveOrders (OrderId, SolverId, RowNo)
	select 
		o.OrderId, 
		o.SolverId, 
		o.RowNo
	from #dopCollectiveOrders o
		join
		(
			select 
				distinct o.OrderId
			from
				#dopCollectiveOrders o
			where
				o.RowNo > 1
				
		) d on d.OrderId = o.OrderId

	-- Рассчитываем частичные суммы для совместно решенных задач
	update o
	set
		o.OrderSum = round(ord.ProductsSum / u.UsersCount, 2)
	from 
		#collectiveOrders o
		join
		(	
			select o.OrderId, count(*) as 'UsersCount'
			from #collectiveOrders o
			group by o.OrderId
		) u on u.OrderId = o.OrderId
		join #orders ord on ord.Id = o.OrderId 

	-- Колличество проблемных заказов
	select @OrdersCount = count(distinct OrderId) from #tasksForCount
	
	-- Колличество решенных заказов
	select @SlovedOrdersCount =	count(distinct OrderId) 
		from 
			#tasksForCount t
		where 
			OrderId in 
			(
				select 
					OrderId 
				from
					#tasksForCount t
					join CLIENTORDERS o on o.ID = t.OrderId
				where
					o.STATUS not in (3, 6)			
					and 
					(t.ThreadSolvedResultId = 1 or t.TaskCategoryId = 2)
			) 

	-- Заполнение отчета 
	insert #report (UserID, OrdersCount, OrdersSum)
	select 
		t.SolverId,
		sum(1),
		sum(t.OrderSum)
	from
	(
		select t.OrderId, t.SolverId, t.OrderSum from #solvedOrders t
		where 
		t.OrderId not in (select OrderId from #collectiveOrders)
		union all 
		select ct.OrderId, ct.SolverId, ct.OrderSum from #collectiveOrders ct
	) t	
	group by 
		t.SolverId

	-- Получение данных по груповому плану
	select 
		u.LastName + ' ' + u.FirstName	as 'FIO',
		r.UserID						as 'UserId',
		r.OrdersCount					as 'OrdersCount',
		r.OrdersSum						as 'OrdersSum'
	from 
		#report r
		join USERS u on u.ID = r.UserID
	where
		u.RoleId = 22
	order by u.LastName + ' ' + u.FirstName

	
end
