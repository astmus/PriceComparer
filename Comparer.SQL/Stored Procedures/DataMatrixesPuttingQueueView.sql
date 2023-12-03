create proc DataMatrixesPuttingQueueView
(
	@Limit			int			-- количество получаемых маркировок 	
)
as
begin
	
	if (@Limit is null)
		select @Limit = 50
		
	select top (@Limit)
		q.DataMatrix
	from
		DataMatrixCRPTPuttingQueue q
	order by 
		q.Id

end
