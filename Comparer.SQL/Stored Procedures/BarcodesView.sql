create procedure BarcodesView (@Limit int, @offset int, @UseSkus bit) as
begin

	if @UseSkus = 1
	begin
		select B.SKU, B.BarCode, B.BarFormat
		from #useSkus A
		join BarCodes B on B.SKU=A.SKU
		where B.BarFormat in ('GTIN-12', 'GTIN-13') and ValidSign=1
		order by B.SKU, B.BarCode

		return 0
	end

	if @Limit is not null and @offset is not null
	begin
		with BarCodesNumber AS
		(
			select row_number() over (order by SKU, BarCode) as RowNumber, *
			from BarCodes
			where BarFormat in ('GTIN-12', 'GTIN-13') and ValidSign=1
		)
		select SKU, BarCode, BarFormat
		from BarCodesNumber
		where RowNumber BETWEEN @offset AND @offset + @Limit - 1

		return 0
	end

	select SKU, BarCode, BarFormat
	from BarCodes
	where BarFormat in ('GTIN-12', 'GTIN-13') and ValidSign=1
	order by SKU, BarCode

	return 0

end
