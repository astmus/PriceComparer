create proc DeliveryServicePrinterConfigurationsView as
begin

	select
		c.Id as 'Id',
		c.WorkplaceName as 'WorkplaceName',
		c.A4Printer as 'A4Printer',
		c.LabelPrinters as 'LabelPrinters'
	from DeliveryServicePrinterConfigurations c
	order by c.WorkplaceName

end
