create proc DeliveryServicePrinterConfigurationEdit (
	@Id				int,					-- Идентификатор конфигурации
	@WorkplaceName	nvarchar(255),			-- Имя рабочего места
	@A4Printer		nvarchar(500),			-- Принтер для печати формата А4
	@LabelPrinters	nvarchar(4000)			-- Принтеры для печати этикеток
) as
begin
	
	set nocount on
		
	begin try
	
		-- Создаем запись в основной таблице			
		update DeliveryServicePrinterConfigurations 
		set WorkplaceName = @WorkplaceName, 
			A4Printer = @A4Printer, 
			LabelPrinters = @LabelPrinters
		where Id = @Id
		
		return 0
	end try
	begin catch
		return 1
	end catch

end
