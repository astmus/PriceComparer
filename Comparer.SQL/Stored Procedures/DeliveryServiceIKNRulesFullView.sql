create proc DeliveryServiceIKNRulesFullView as
begin

	-- Основная информация
	select	r.Id				as 'Id',
			r.IknId				as 'IknId', 
			isnull(i.Name,'?')	as 'IknValue', 
			r.Name				as 'Name', 
			r.OrderNum			as 'OrderNum'
	from ApiDeliveryServicesIKNRules r
		left join ApiDeliveryServicesIKNs i on i.Id = r.IknId
	order by r.OrderNum

	-- Условия
	select	c.Id		as 'Id', 
			c.RuleId	as 'RuleId', 
			c.CType		as 'CType', 
			c.Args		as 'Args'
	from ApiDeliveryServicesIKNRuleConditions c
	order by c.CType

	-- Ограничения
	select	c.Id		as 'Id', 
			c.RuleId	as 'RuleId', 
			c.CType		as 'CType', 
			c.Args		as 'Args'
	from ApiDeliveryServicesIKNRuleConstraints c
	order by c.CType

end
