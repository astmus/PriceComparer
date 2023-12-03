create proc UsersPlanReportCallCountEdit
(
	@Date				date
)
as
begin
	create table #updatedUsers
	(
		ManagerId	uniqueidentifier	not	null,
		CallCount	int						null,
		RowID		int						null
	)

	insert #updatedUsers (ManagerId, CallCount, RowID)
	select 
		c.ManagerId,
		c.CallCount,
		c1.Id
	from 
		#ManagersCallsCount c
		left join UsersPlanReportCallCount c1 on c1.UserID = c.ManagerId and MONTH(c1.Date) = MONTH(@Date) and YEAR(c1.Date) = YEAR(@Date)

	insert UsersPlanReportCallCount (UserID, CallCount, Date)
	select 
		ManagerId,
		CallCount,
		@Date
	from #updatedUsers
	where RowID is null

	update c
	set 
		c.CallCount = u.CallCount
	from 
		UsersPlanReportCallCount c
		join #updatedUsers u on u.RowID = c.Id
	where 
		c.Id = u.RowID

end
