create proc StoredBarcodesView
as
begin

	select
		b.SKU			as 'SKU',
		b.BarCode		as 'Barcode'
	from 
		Barcodes b
	where 
		len(b.BarCode) >= 8 and len(b.BarCode) <= 14

end
