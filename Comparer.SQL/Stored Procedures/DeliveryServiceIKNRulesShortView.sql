create proc DeliveryServiceIKNRulesShortView as
begin

	select	r.Id				as 'Id',
			r.IknId				as 'IknId', 
			isnull(i.Name,'?')	as 'IknValue', 
			r.Name				as 'Name', 
			r.OrderNum			as 'OrderNum'
	from ApiDeliveryServicesIKNRules r
		left join ApiDeliveryServicesIKNs i on i.Id = r.IknId
	order by r.OrderNum

end
