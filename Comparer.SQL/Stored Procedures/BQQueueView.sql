create proc BQQueueView
(
	@ObjectTypeId	int,
	@PublicId		uniqueidentifier
)
as
begin
	
	select 
		q.Id,
		q.PublicId,
		q.ObjectTypeId,
		q.Data,
		q.Error,
		q.TryCount,
		q.NextTryDate
	from BQQueue q
	where
		q.ObjectTypeId = @ObjectTypeId
		and (NextTryDate is null or q.NextTryDate < getdate())
		and (@PublicId is null or @PublicId = q.PublicId)
	order by
		q.CreatedDate asc

end
