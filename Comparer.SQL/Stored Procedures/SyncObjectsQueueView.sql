create proc SyncObjectsQueueView as
begin
	
	select	Id			as 'QueueId',
			ClassId		as 'ClassId',
			ObjectId	as 'ObjectId',
			Method		as 'Method'
	from SyncObjectsQueue 
	order by Id

end
