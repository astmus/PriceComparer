create proc VoximplantOrdersForConfirmView as
begin

	select v.OrderId
	from VoximplantOrders v
		join CLIENTORDERS o on o.ID = v.OrderId and o.[STATUS] in (1, 7)
	where
		v.ScenarioId = 1 
		and v.StatusId in (1, 4, 6)
end
