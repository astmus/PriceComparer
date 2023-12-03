create proc SyncObjectsQueueView_v2 
(
	@Limit int = null
)	
 as
begin
	
	-- Костыль!!!
	-- Удаляем все объекты Бренды и Товары
	delete SyncObjectsQueue where ClassId in (1,2)

	if (@Limit is null)
		
		select  
			Id			as 'Id',
			ClassId		as 'ClassId',
			ObjectId	as 'ObjectId',
			Method		as 'Method',
			CreatedDate as 'CreatedDate',
			Data		as 'Data'
		from SyncObjectsQueue 
		--where 
			-- TryCount < 3 --and (NextTryDate is null)
		order by Id
		
	else
			with outMessages as
			(
				select row_number() over (order by Id) as RowNo, *
				from SyncObjectsQueue
			)
			select 
				Id			as 'Id',
				ClassId		as 'ClassId',
				ObjectId	as 'ObjectId',
				Method		as 'Method',
				CreatedDate as 'CreatedDate',
				Data		as 'Data'
			from outMessages
			where RowNo <= @Limit  
				--	and TryCount < 3 and (NextTryDate is null or (NextTryDate is not null and getdate() > NextTryDate))
			order by Id 
end
