create proc SyncOrderView
(
	@OrderId		uniqueidentifier		-- Идентификатор заказа
) as
begin
	
	select 
		-- Заказ
		ID						as 'Id',
		PUBLICNUMBER			as 'PublicNumber',
		DISPATCHNUMBER			as 'DispatchNumber',
		[DATE]					as 'CreatedDate',
		ExpectedDate			as 'ExpectedDate',
		SITEID					as 'SiteId',
		KIND					as 'KindId',
		DELIVERYKIND			as 'DeliveryId',
		PAYMENTKIND				as 'PaymentId',
		DELIVERY				as 'Delivery',
		FEE						as 'Fee',
		FROZENSUM				as 'Sum',
		PAIDSUM					as 'PaidSum',
		CLIENTID				as 'ClientId',
		[STATUS]				as 'StatusId',
		-- Внешний заказ
		so.PublicId				as 'PublicId',
		-- Причина возврата
		orr.ReasonId			as 'CancelReasonId',
		orr.AnotherReason		as 'CancelReason'
	from 
		CLIENTORDERS o
		join ClientOrdersSync so on so.OrderId = o.ID
		left join OrderReturnReasons orr on orr.OrderId = o.Id 
	where 
		o.ID = @OrderId 

	-- Товарные позиции
	select
		-- Товар
		p.ID				as 'Id',
		p.SKU				as 'Sku',
		-- Позиция в заказе 
		c.QUANTITY			as 'Quantity'
	from 
		CLIENTORDERSCONTENT c
		join PRODUCTS p on p.ID = c.PRODUCTID
		left join ProductsSync ps on ps.ProductId = p.ID

	
end
