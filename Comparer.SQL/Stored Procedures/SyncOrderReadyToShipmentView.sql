create proc SyncOrderReadyToShipmentView 
(
	@OrderId		uniqueidentifier		-- Идентификатор заказа
) as
begin

	select 
		so.PublicId				as 'PublicId',
		o.PUBLICNUMBER			as 'PublicNumber',
		o.DISPATCHNUMBER		as 'DispatchNumber',
		s.ID					as 'SiteId',
		s.NAME					as 'SiteName'
	from CLIENTORDERS o 
		join ClientOrdersSync so on so.OrderId = o.ID
		join SITES s on s.ID = o.SITEID
	where o.ID = @OrderId

	select
		sp.PublicSku					as 'PublicSku', 
		p.Sku							as 'Sku', 
		c.QUANTITY						as 'Quantity'
	from CLIENTORDERS o  
		join CLIENTORDERSCONTENT c on o.ID = c.CLIENTORDERID
		join Products p on c.PRODUCTID = p.ID
		join ProductsSync sp on p.Id = sp.ProductId and o.SiteId  = sp.SiteId
	where o.ID = @OrderId
	
end
