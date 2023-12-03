create proc VoxplantOrderSave (
	@OrderId		uniqueidentifier,	--	Идентификатор 
	@StatusId		int,				--  Статус
	@ChangeDate		DateTime			--  Дата записи
)as
begin

	if (not exists (select 1 from VoximplantOrders vo where vo.OrderId = @OrderId)) begin
		insert VoximplantOrders (OrderId,StatusId,ChangedDate)
		values (@OrderId,@StatusId,isnull(@ChangeDate,getdate()))
	end
end
