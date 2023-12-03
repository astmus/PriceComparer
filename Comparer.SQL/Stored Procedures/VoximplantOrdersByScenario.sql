create proc VoximplantOrdersByScenario
(
	@ScenarioId			int		-- Идентификатор сценария
)
 as
begin

	select 
		v.OrderId
	from 
		VoximplantOrders v
			join CLIENTORDERS o on o.ID = v.OrderId and o.[STATUS] in (1, 7)
	where 
		v.ScenarioId = @ScenarioId
		and (v.StatusId = 1 or (@ScenarioId = 1 and v.StatusId = 6))
end
