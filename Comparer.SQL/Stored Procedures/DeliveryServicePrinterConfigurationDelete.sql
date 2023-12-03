create proc DeliveryServicePrinterConfigurationDelete (
	@Id		int		-- Идентификатор конфигурации
) as
begin
	
	set nocount on
		
	begin try
	
		delete DeliveryServicePrinterConfigurations where Id = @Id
		
		return 0
	end try
	begin catch
		return 1
	end catch

end
