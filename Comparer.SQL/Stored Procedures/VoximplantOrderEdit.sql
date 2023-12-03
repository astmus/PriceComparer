create proc VoximplantOrderEdit 
(
	@OrderId		uniqueidentifier,
	@StatusId		int,
	@Error			nvarchar(4000)
) as
begin

	update VoximplantOrders
	set 
		StatusId		= @StatusId,
		Error			= @Error,
		ChangedDate		= getdate()
	where OrderId = @OrderId

end
