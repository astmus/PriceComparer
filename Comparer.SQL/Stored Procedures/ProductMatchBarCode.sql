create proc ProductMatchBarCode 
as
begin
/*
	select 
		bc.Sku		as 'Sku', 
		p.Id		as 'ProductId',
		p.Name		as 'Name',
		Gtin		as 'Gtin'
 	from BarCodes bc 
		join #Gtins g on g.Gtin = bc.BarCode
		join Products p on p.Sku = bc.Sku
*/
	select 	
		p.Sku		as 'Sku', 
		p.Id		as 'ProductId',
		p.Name		as 'Name',
		Gtin		as 'Gtin'
 	from BarCodeProductIdLinks bc 
		join #Gtins g on g.Gtin = bc.BarCode
		join Products p on p.Id = bc.ProductId

end
