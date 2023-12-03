create procedure Barcodes1CView (@RepDate datetime) as
begin

	select b.SKU as 'РђСЂС‚РёРєСѓР»', b.BarCode as 'РљРѕРґ', isnull(s.BatchBegin, '') as 'Р”Р°С‚Р°' 
	from BarCodes b
		left join BarCodesSessionBatches s on s.BatchBegin = b.BatchNo1РЎ and s.BatchBegin >= @RepDate
	--where ReportDate >= @RepDate

end
