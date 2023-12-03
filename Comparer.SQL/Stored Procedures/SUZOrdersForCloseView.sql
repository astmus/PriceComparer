create proc SUZOrdersForCloseView
as
begin

	select 
		top 100
		o.Id,
		o.PublicId,
		o.IsActive,
		o.StatusId,
		o.ClosedDate,
		o.CreatedDate,
		o.SourceId,
		o.MustBeClosed,
		o.Error				as 'Error'
	from 
		SUZOrders o
	where
		o.IsActive = 1 and
		o.MustBeClosed = 1

end
