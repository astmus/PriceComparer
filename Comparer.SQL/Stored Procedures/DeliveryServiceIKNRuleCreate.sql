create proc DeliveryServiceIKNRuleCreate (
	@IknId			int,			-- Идентификатор ИКН
	@Name			nvarchar(255),	-- Имя правила
	@NewId			int	out			-- Идентификатор созданного правила
) as
begin

	set @NewId = 0;

	begin try

		declare @nextNum int = 1
		if exists(select 1 from ApiDeliveryServicesIKNRules r)
			select @nextNum = (select max(r.OrderNum) + 1 from ApiDeliveryServicesIKNRules r)

		-- Вставляем правило
		insert ApiDeliveryServicesIKNRules(IknId, Name, OrderNum) 
		values (@IknId, @Name, @nextNum)
		set @NewId = @@identity

		-- Вставляем условия
		insert ApiDeliveryServicesIKNRuleConditions (RuleId, CType, Args)
		select @NewId, ConditionType, Args
		from #ruleConditions

		-- Вставляем ограничения
		insert ApiDeliveryServicesIKNRuleConstraints (RuleId, CType, Args)
		select @NewId, ConstraintType, Args
		from #ruleConstraints

		return 0
	end try
	begin catch
		return 1
	end catch

end
