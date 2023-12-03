create proc GetOrderContextForDefineScenario (
	@OrderId		uniqueidentifier	--	РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ 
)as
begin
	select 	
	Id as 'OrderId',
	ChangeDate as 'ChangedDate',
	Status as 'Status'
	from ClientOrders
	where Id=@OrderId
end
