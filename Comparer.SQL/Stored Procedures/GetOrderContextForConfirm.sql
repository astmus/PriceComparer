create proc GetOrderContextForConfirm 
(
	@OrderId	uniqueidentifier	--	Идентификатор 
)as
begin

  select
	  co.PublicNumber as 'PublicNumber',
	  cl.Name as 'FirstName',
	  cl.LastName as 'LastName',
	  cl.FatherName as 'FatherName',
	  co.MOBILE as 'Phone',
	  co.Email as 'Email',
	  co.DELIVERY_INFO as 'DeliveryData',
	  co.FrozenSum as 'Sum',
	  ca.FirstName as 'ContactFirstName',
	  ca.LastName as 'ContactLastName',
	  ca.MiddleNAME as 'ContactFatherName',
	  ca.CONTACTPHONE as 'ContactPhone',
	  ca.Region as 'Region',
	  ca.District as 'District',
	  ca.City as 'City',
	  ca.Street as 'Street',
	  ca.House as 'House',
	  ca.House_Type as 'House_Type',
	  ca.Block as 'Block',
	  ca.Block_Type as 'Block_Type',
	  ca.Flat as 'Flat',
	  ca.Flat_Type as 'Flat_Type',
	  ca.ZipCode as 'ZipCode',
	  ca.COUNTRYID as 'CountryId',
	  ca.AOGuid as 'AOGuid',
	  ca.Autonomarea as 'Autonomarea',
	  ca.Urbanarea as 'Urbanarea',
	  ca.Locality as 'Locality',
	  ca.Fiasstatus as 'Fiasstatus',
	  ca.SendSms as 'SendSms', 
	  ca.DISTANCECOURIER as 'DistanceCourier',
	  d.DeliveryServiceId as 'DeliveryServiceId',
	  d.DeliveryKindId as 'DeliveryKindId',
	  l.DeliveryDateFrom as 'DeliveryDateFrom',
	  l.DeliveryDateTo as 'DeliveryDateTo'

  from ClientOrders co
	  join Clients cl on cl.Id=co.CLIENTID
	  left join ClientOrderAddresses ca on ca.ClientorderId = co.Id
	  left join ClientOrdersDelivery d on d.OrderId = co.Id
	  left join OrderDeliveryLogistics l on l.ClientOrderID = co.Id

  where 
	co.Id = @OrderId
  
  select 
	p.Name as 'Name',
	coc.Quantity as 'Quantity',
	case d.DeliveryKindId
		when 5 then count(isnull(pr.Price,0))
		when 16 then count(isnull(pr.Price,0))
		when 21 then count(isnull(pr.Price,0))
		else 
			coc.FrozenRetailPrice
	end
	as 'Price',

	case d.DeliveryKindId
		when 5 then  count(isnull(cast (pr.Price as int),0))
		when 16 then count(isnull(cast(pr.Price as int),0))
		when 21 then count(isnull(cast(pr.Price as int),0))
		else 
			p.INSTOCK-p.ReserveStock-p.PassiveReserveStock 
	end
	as 'Stock'

  from ClientOrdersContent coc
	  join Products p on p.Id = coc.ProductId
	  join SiteProducts sp on sp.ProductId = p.Id and sp.SITEID = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'
	  join ClientOrdersDelivery d  on d.OrderId = coc.ClientOrderId 
	  left join Links l on l.CatalogProductId = p.Id
	  left join PricesRecords pr on pr.RecordIndex = l.PriceRecordIndex and pr.Deleted = 0
  where 
	coc.ClientOrderId = @OrderId
  group by 
	p.Name, coc.Quantity, d.DeliveryKindId, coc.FrozenRetailPrice, 
	p.INSTOCK, p.ReserveStock, p.PassiveReserveStock 
  
end
