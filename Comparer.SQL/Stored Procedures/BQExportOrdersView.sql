create proc BQExportOrdersView
as
begin
	
	select 
		o.Id, 
		o.OrderId
	from BQExportOrders o
	order by
		o.ReportDate

end
