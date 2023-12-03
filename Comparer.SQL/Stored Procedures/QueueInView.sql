create proc QueueInView
(
	@PublicId		nvarchar(50)	= null,		-- Идентификатор обмена
	@Limit			int				= null		-- Максимальное количество загружаемых сообщений<
) as
begin

	if @PublicId is not null begin

		select Id, PublicId, ClassId, TypeId, Sender, Body, CreatedDate, isnull(Error,'') as 'Error'
		from SyncQueueIn
		where PublicId = @PublicId
		order by CreatedDate

	end else 
	if @Limit is not null begin

		with inMessages as
		(
			select row_number() over (order by CreatedDate) as RowNo, *
			from SyncQueueIn
		)
		select Id, PublicId, ClassId, TypeId, Sender, Body, CreatedDate, isnull(Error,'') as 'Error'			
		from inMessages
		where RowNo <= @Limit and TryCount < 5 and (NextTryDate is null or (NextTryDate is not null and getdate() > NextTryDate))
		
	end else begin
	
		select Id, PublicId, ClassId, TypeId, Sender, Body, CreatedDate, isnull(Error,'') as 'Error'
		from SyncQueueIn
		where TryCount < 5 and (NextTryDate is null or (NextTryDate is not null and getdate() > NextTryDate))
		order by CreatedDate

	end

end
