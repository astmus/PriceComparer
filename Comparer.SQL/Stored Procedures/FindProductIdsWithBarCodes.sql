create proc FindProductIdsWithBarCodes
as
begin
 select distinct
  p.Name	as 'Name',
  b.Sku		as 'Sku',
  p.Id		as 'ProductId',
  b.BarCode	as 'BarCode'
  from BarCodes b
  join Products p on p.Sku=b.Sku
  join #BarCodes bc on bc.BarCode=b.BarCode

  where b.ValidSign=1

 
end
