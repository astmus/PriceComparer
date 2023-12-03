create proc DeliveryServiceIKNRuleDelete (
	@Id		int		-- Идентификатор правила	
) as
begin

	begin try
		
		-- Удаляем правило
		delete ApiDeliveryServicesIKNRules where Id = @Id

		-- Удаляем условия
		delete ApiDeliveryServicesIKNRuleConditions where RuleId = @Id

		-- Удаляем ограничения
		delete ApiDeliveryServicesIKNRuleConstraints where RuleId = @Id
		
		return 0
	end try
	begin catch
		return 1
	end catch

end
