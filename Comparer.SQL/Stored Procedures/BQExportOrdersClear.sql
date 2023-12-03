create proc BQExportOrdersClear
as
begin
	
	delete o
	from #exportIds e
		join BQExportOrders o on o.Id = e.Id

end
