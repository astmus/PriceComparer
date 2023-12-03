create proc DeliveryServiceIKNRuleEdit (
	@Id				int,			-- Идентификатор правила
	@IknId			int,			-- Идентификатор ИКН	
	@Name			nvarchar(255),	-- Имя правила	
	@OrderNum		int				-- Порядковый номер
) as
begin

	begin try

		-- Обновляем правило
		update ApiDeliveryServicesIKNRules
		set	IknId = @IknId,
			Name = @Name,
			OrderNum = @OrderNum
		where Id = @Id

		-- Обновляем условия
		delete c
		from ApiDeliveryServicesIKNRuleConditions c
			left join #ruleConditions t on c.Id = t.Id
		where c.Id = @Id and t.Id is null

		update c
		set c.Args = t.Args
		from #ruleConditions t
			join ApiDeliveryServicesIKNRuleConditions c on c.Id = t.Id
		where c.Id = @Id
		 
		insert ApiDeliveryServicesIKNRuleConditions (RuleId, CType, Args)
		select @Id, t.ConditionType, t.Args
		from #ruleConditions t
			left join ApiDeliveryServicesIKNRuleConditions c on c.Id = t.Id and c.Id = @Id
		where c.Id is null
	
		-- Обновляем ограничения
		delete c
		from ApiDeliveryServicesIKNRuleConstraints c
			left join #ruleConstraints t on c.Id = t.Id
		where c.Id = @Id and t.Id is null
		
		update c
		set c.Args = t.Args
		from #ruleConstraints t
			join ApiDeliveryServicesIKNRuleConstraints c on c.Id = t.Id
		where c.Id = @Id
		 
		insert ApiDeliveryServicesIKNRuleConstraints (RuleId, CType, Args)
		select @Id, t.ConstraintType, t.Args
		from #ruleConstraints t
			left join ApiDeliveryServicesIKNRuleConstraints c on c.Id = t.Id and c.Id = @Id
		where c.Id is null

		return 0
	end try
	begin catch
		return 1
	end catch

end
