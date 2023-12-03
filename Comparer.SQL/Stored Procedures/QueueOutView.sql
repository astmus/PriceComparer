create proc QueueOutView
(
	@PublicId		nvarchar(50) = null		-- Идентификатор обмена
) as
begin

	select Id, PublicId, ClassId, Receivers, Body, CreatedDate, isnull(Error,'') as 'Error', ErrorStatus
	from SyncQueueOut
	where TryCount < 5 and (NextTryDate is null or (NextTryDate is not null and getdate() > NextTryDate))

end
