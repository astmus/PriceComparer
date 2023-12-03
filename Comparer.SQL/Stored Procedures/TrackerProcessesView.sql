create proc TrackerProcessesView
as
begin	

	select 
		Id, AccountId, StateId, StartTrackingDate, 
		OrderCountLimit, DelayBetweenStages, Errors,	
		IsActive
	from 
		ApiDeliveryServiceTrackers
	where 
		IsActive = 1 
		and StartTrackingDate is not null
	order by Id

	return  0
end
