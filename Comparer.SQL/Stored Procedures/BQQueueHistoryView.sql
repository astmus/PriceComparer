create proc BQQueueHistoryView
as
begin
	
	select top 25000
		b.Id, b.Type, b.Data
	from
		BQQueueHistory b with (nolock)
	order by 
		Id

end
