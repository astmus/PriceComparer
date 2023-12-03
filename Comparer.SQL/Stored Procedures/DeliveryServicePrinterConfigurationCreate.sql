create proc DeliveryServicePrinterConfigurationCreate (
	@WorkplaceName	nvarchar(255),			-- Имя рабочего места
	@A4Printer		nvarchar(500),			-- Принтер для печати формата А4
	@LabelPrinters	nvarchar(4000),			-- Принтеры для печати этикеток
	-- Выходные параметры
	@NewId			int out					-- Идентификатор созданной конфигурации
) as
begin
	
	set nocount on
	set @NewId = 0
		
	begin try
	
		-- Создаем запись в основной таблице			
		insert DeliveryServicePrinterConfigurations (WorkplaceName, A4Printer, LabelPrinters)
		values (@WorkplaceName, @A4Printer, @LabelPrinters)

		set @NewId = @@IDENTITY
		
		return 0
	end try
	begin catch
		return 1
	end catch

end
