create proc  UTOrderContentPricesView_v2
(
	@PublicNumber	nvarchar(20)
)
as
begin
	
	declare @OrderId	uniqueidentifier
	select  @OrderId=Id from  ClientOrders   where PublicNumber=@PublicNumber

	-- Находим цены УТ
	declare @UTPrices table
	(
		ProductId	uniqueidentifier,
		Price		float,
		CurrencyId	int,
		DocNumber	nvarchar(64),		
		DocDate		datetime		
	) 

	insert @UTPrices exec  UtPricesOrderContent_v2 @OrderId

	-- Соединяем цыны УТ с позициями заказа
	select  distinct
		 c.ProductId											as 'ProductId',
		 p.Sku													as 'Sku',
		 dbo.ParseBarCodeFromDataMatrix(odm.DataMatrix)			as 'DataMatrix', 
		 m.Name													as 'BrandName', 
		 p.Name+' '+p.ChildName									as 'Name',
		 c.FrozenRetailPrice									as 'FrozenRetailPrice',
		 u.Price												as 'UtPriceCurrency',
		 u.CurrencyId											as 'CurrencyId',
		 u.DocDate												as 'DocDate',
		 u.DocNumber											as 'DocNumber'						
	from ClientOrdersContent c 
		join Products p on p.Id=c.ProductId
		join Manufacturers m on m.Id=p.ManId
		left join @UTPrices u on u.ProductId=p.Id
		left join OrderContentDataMatrixes odm  on  odm.OrderId=@OrderId and  odm.ProductId=c.ProductId 
		group by c.ClientOrderId, c.ProductId, p.Sku,  dbo.ParseBarCodeFromDataMatrix(odm.DataMatrix),  m.Name, p.Name+' '+p.ChildName,c.FrozenRetailPrice,	u.Price,  u.CurrencyId,  u.DocDate,	 u.DocNumber
	having c.ClientOrderId = @OrderId 
	

end


--
--   exec UTOrderContentPricesView '121-0818-9632', '18.08.2021'


--	select  Id from  ClientOrders   where PublicNumber='121-0818-9632'

--	exec  UtPricesOrderContent 'CA0E142C-5804-4A4E-A828-87F98372C79C', '18.08.2021'
