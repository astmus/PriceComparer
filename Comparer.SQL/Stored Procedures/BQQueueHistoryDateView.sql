create proc BQQueueHistoryDateView
as
begin
	select
		d.HistoryDate as 'HistoryDate'
	from 
		BQQueueHistoryDate d

end
