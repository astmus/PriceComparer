create procedure BarCodesRecQuantity as
begin

	select count(1) as RecordQuantity 
	from BarCodes
	where BarFormat in ('GTIN-12', 'GTIN-13') and ValidSign=1

end
