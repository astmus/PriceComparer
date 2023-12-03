create proc UserActivityBatchItemsView
(	
	@BatchId			bigint					-- Идентификатор пачки
) as
begin
	
	select 
			i.BatchId		as	'BatchId',
			i.ActionId		as  'ActionId'
	from 
		ActivityBatchItems i
	where
		i.BatchId = @BatchId
		
end
