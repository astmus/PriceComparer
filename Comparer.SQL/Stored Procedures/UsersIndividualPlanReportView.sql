create proc UsersIndividualPlanReportView
(	
	@BeginDate			date,
	@EndDate			date,
	@SolvedOrdersCount		int	out
) as
begin

	--      
	create table #history 
	(
		OrderId			uniqueidentifier	not null, 
		StatusId		int					not null,
		UserId			uniqueidentifier	not null,
		StatusDate      datetime            not null
		primary key (OrderId, StatusId, UserId, StatusDate)
	)
	insert #history (OrderId, StatusId, UserId, StatusDate)
	select distinct h.CLIENTORDER, h.STATUS, isnull(u.ID, '00000000-0000-0000-0000-000000000000'), STATUSDATE
	from ORDERSSTATUSHISTORY h
		left join USERS u on u.NAME = h.AUTHOR
	where 
		cast(h.STATUSDATE as date) >= @BeginDate
		and cast(h.STATUSDATE as date) <= @EndDate
		and h.STATUS in (2, 3, 4, 5)
		
	--   
	create table #ConfirmedHistory
	(
		OrderId			uniqueidentifier	not null, 
		UserId			uniqueidentifier	not null
		primary key (OrderId, UserId)
	)
	insert #ConfirmedHistory (OrderId, UserId)
	select 
		h.OrderId, h.UserId
	from
	(
		select 
			h.OrderId, 
			h.UserId, 
			row_number() over(partition by h.OrderId order by h.StatusDate) as 'RowNum'
		from 
			#history h
		where 
			h.StatusId = 2
	) h
	where 
		h.RowNum = 1

	--    ( )
	create table #ConfirmedOrders
	(
		OrderId 		uniqueidentifier	not null,
		UserId			uniqueidentifier	not null
		primary key (OrderId, UserId)
	)
	
	insert #ConfirmedOrders (OrderId, UserId)
	select 
		o.ID, u.ID
	from 
		CLIENTORDERS o
		join CLIENTS c on c.ID = o.CLIENTID
		join USERS u on u.ID = o.CREATORID
		join #ConfirmedHistory ch on ch.OrderId = o.ID and ch.UserId = o.CREATORID
	where 
		o.KIND = 2	--   
		and u.DepartmentId = 7
		and u.RoleId not in (21, 49, 19)	--  ,  ,   ;
		and c.IsEmployee = 0 
		and o.STATUS not in (1,3,8,7)

	--   
	create table #ProcessedOrders
	(
		OrderId			uniqueidentifier	not null,
		UserId			uniqueidentifier	not null
		primary key (OrderId, UserId)
	)

	insert #ProcessedOrders (OrderId, UserId)
	select 
		distinct au.ObjectId as 'OrderId', au.UserId as 'UserId'
	from 
		ActivityUserBatch au
		join ActivityBatchItems ab on ab.BatchId = au.Id
		join CLIENTORDERS o on o.ID = au.ObjectId 
		join CLIENTS c on c.ID = o.CLIENTID
		join USERS u on u.ID = au.UserId
	where 
		cast(au.CreatedDate as date) >= @BeginDate
		and cast(au.CreatedDate as date) <= @EndDate
		and u.DepartmentId = 7
		and u.RoleId not in (21, 49, 19)	--  ,  ,   ;
		and c.IsEmployee = 0
		and ab.ActionId in (1,2,3,4,6,7,8)

	--   
	create table #CancelledHistory
	(
		OrderId			uniqueidentifier	not null, 
		UserId			uniqueidentifier	not null
		primary key (OrderId, UserId)
	)

	insert #CancelledHistory (OrderId, UserId)
	select 
		o.OrderId, o.UserId
	from
	(
		select 
			h.OrderId, h.UserId, 
			row_number() over(partition by h.OrderId order by h.StatusDate desc) as 'RowNum'
		from 
			#history h
		where 
			h.StatusId = 3
	) o 
	where
		o.RowNum = 1

	--   
	create table #CancelledOrders
	(
		OrderId			uniqueidentifier	not null,
		UserId			uniqueidentifier	not null
		primary key (OrderId, UserId)
	)
	insert #CancelledOrders (OrderId, UserId)
	select 
		ch.OrderId, ch.UserId		
	from 
		#CancelledHistory ch
		join CLIENTORDERS o on o.ID = ch.OrderId
		join USERS u on u.ID = ch.UserId
		join CLIENTS c on c.ID = o.CLIENTID
		left join OrderReturnReasons r on r.OrderId = o.ID
	where 
		c.IsEmployee = 0
		and u.DepartmentId = 7
		and u.RoleId not in (21, 49, 19)	--  ,  ,   ;
		and o.STATUS in (3, 6)
		and isnull(r.ReasonId, -1) not in (1002, 59, 70)

	--   
	create table #ReceivedOrders
	(
		OrderId			uniqueidentifier		not null,
		UserId			uniqueidentifier		not null
		primary key (OrderId, UserId)
	)

	insert into #ReceivedOrders (OrderId, UserId)
	select 
		distinct o.ID, u.ID
	from 
		CLIENTORDERS o
		join USERS u on u.ID = o.CREATORID 
		join #history rh on rh.OrderId = o.ID and rh.StatusId = 5
	where 
		o.KIND = 1	--  
		and u.DepartmentId = 7		
		and u.RoleId not in (21, 49, 19)	--  ,  ,   ;
	
	--  
	create table #tasks
	(
		ThreadSolverId			uniqueidentifier	null,
		OrderId					uniqueidentifier	not null,
		ThreadId				int					not null,
		TaskId					int					not null,
		ThreadSolvedResultId	int					null,
		TaskCategoryId			int					not null,
		SolverRoleId			int					null,
		OrderStatusId			int					not null,
		TaskSolvedResultId		int					not null

		primary key (OrderId, ThreadId, TaskId)
	)

	insert into #tasks (ThreadSolverId, OrderId, ThreadId, TaskId, ThreadSolvedResultId, TaskCategoryId, SolverRoleId, OrderStatusId, TaskSolvedResultId)
	select 
		u.ID, o.ID, th.Id, t.Id, th.SolveResultId, t.CategoryId, u.RoleId, o.STATUS, t.SolveResultId
	from 
		OrderProblemTaskThreads th
		join OrderProblemTasks t on t.Id = th.TaskId
		join CLIENTORDERS o on o.ID = t.OrderId
		join Users kc on kc.ID = t.AuthorId
		left join Users u on u.ID = th.SolverId
		left join Users uth on uth.ID = th.UserId
	where
		o.KIND in (1, 2)
		and t.CategoryId not in (99)		--   ,  
		and t.LevelId = 2
		--and o.STATUS not in (3,6)
		--and u.RoleId not in (21, 49, 19)	--  ,  ,   ;
		and
		(
			(
				th.SolverId is not null
				and th.StatusId = 3
				and th.SolveResultId in (1,2)
				--and
				--(
				--	th.SolveResultId = 1
				--	or
				--	(t.CategoryId = 2 and th.SolveResultId = 2)
				--)
				and u.DepartmentId = 7
				and cast(th.SolvedDate as date) >= @BeginDate
				and cast(th.SolvedDate as date) <= @EndDate	
			)
			or
			(
				th.SolverId is null
				and t.StatusId = 3
				and t.SolveResultId in (1,2)
				--and 
				--(
				--	t.SolveResultId = 1
				--	or
				--	(t.CategoryId = 2 and t.SolveResultId = 2)
				--)
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

	--  
	create table #Orders
	(
		OrderId			uniqueidentifier	not null,
		StatusId		int					not null,
		StatusName		varchar(50)			not null,
		ProductsSum		float				not null
		primary key (OrderId)
	)

	insert #Orders (OrderId, StatusId, ProductsSum, StatusName)
	select 
		o.ID, o.[STATUS], o.FROZENSUM - o.DELIVERY - o.FEE, isnull(st.NAME, '?')
	from
		CLIENTORDERS o
		left join CLIENTORDERSTATUSES st on st.ID = o.[STATUS]
	where
		exists 
		(
			select 1
			from
			(
				select OrderId from #ConfirmedOrders
				union
				select OrderId from #ReceivedOrders
				union
				select OrderId from #CancelledOrders
				union
				select OrderId from #ProcessedOrders
			) e
			where
				e.OrderId = o.ID
		)

	-- 
	select 
	u.ID						as 'UserId', 
	LastName + ' ' + FirstName	as 'FIO',
	cc.CallCount				as 'CallCount'
	from 
	USERS u
	left join UsersPlanReportCallCount cc on cc.UserID = u.ID and MONTH(Date) = MONTH(@BeginDate) and YEAR(Date) = YEAR(@BeginDate)
	where 
	DepartmentId = 7 
	and Status = 1 
	and RoleId not in (21, 49, 19)	--  ,  ,   ;

	select o.OrderId, o.StatusId, o.StatusName, o.ProductsSum from #Orders o
		
	select o.OrderId as 'OrderId', o.UserId as 'UserId' from #ConfirmedOrders o
	select o.OrderId as 'OrderId', o.UserId as 'UserId' from #ProcessedOrders o
	select o.OrderId as 'OrderId', o.UserId as 'UserId' from #CancelledOrders o
	select o.OrderId as 'OrderId', o.UserId as 'UserId' from #ReceivedOrders o
	
	--  
	select
		t.ThreadSolverId	as 'UserId', 
		count(*)			as 'OrdersCount'
	from 
		(
			select 
				distinct OrderId, ThreadSolverId
			from 
				#tasks
			where 
				SolverRoleId not in (21, 49, 19)
				and OrderStatusId not in (3,6)
				and
				(
					(
						ThreadSolverId is not null
						and
						(
							ThreadSolvedResultId = 1
							or
							(TaskCategoryId = 2 and ThreadSolvedResultId = 2)
						)
					)
					or
					(
						ThreadSolverId is null
						and
							(
								TaskSolvedResultId = 1
								or
								(TaskCategoryId = 2 and TaskSolvedResultId = 2)
							)
					)
				)
		) t 
	group by 
		t.ThreadSolverId


	select 
		s.ID								as 'SupervisorId', 
		s.LastName + ' ' + s.FirstName		as 'SupervisorFIO', 
		u.ID								as 'UserId'
	from
		UsersBounds b
		join USERS u on u.ID = b.UserId
		join USERS s on s.ID = b.ParentId
	where
		u.DepartmentId = 7
		and s.RoleId = 21
		and u.RoleId = 22
	order by
		u.LastName, u.FirstName

	

	select @SolvedOrdersCount = count(distinct OrderId) 
		from 
			#tasks t
		where 
			OrderId in 
			(
				select 
					OrderId 
				from
					#tasks t
				where
					 t.OrderStatusId not in (7,8)
			) 
end
