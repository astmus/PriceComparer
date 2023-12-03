create proc BQOrderLastDataView
(
	@OrderId		uniqueidentifier		-- Идентификатор заказа
)
as
begin
	
	-- Заказ
	select  
		-- Заказ общее
		o.OrderId					as 'OrderId',
		o.PublicNumber				as 'PublicNumber',
		o.OrderCreatedDate			as 'OrderCreatedDate',
		o.StatusId					as 'StatusId',

		o.SiteId					as 'SiteId',
		-- Клиент
		o.ClientId					as 'ClientId',
		o.ClientTypeId				as 'ClientTypeId',
		-- Доставка/оплата			
		o.DeliveryTypeId			as 'DeliveryTypeId',
		o.PaymentTypeId				as 'PaymentTypeId',
		
		o.Locality					as 'Locality',
		-- Причины
		o.ReturnReasonId			as 'ReturnReasonId',
		o.FaultPartyId				as 'FaultPartyId',

		o.Coupon					as 'Coupon',
		o.OrdersCount				as 'OrdersCount',
		-- Суммы
		o.DeliveryCost				as 'DeliveryCost',	
		o.FrozenSum					as 'FrozenSum',	
		o.BonusPaidSum				as 'BonusPaidSum',
		o.PaidSum					as 'PaidSum'	

	from BQOrdersLastData o
	where
		o.OrderId = @OrderId

	-- Позиции
	select  
		i.OrderId					as 'OrderId',	
		-- Товар
		i.ProductId					as 'ProductId',
		-- Бренд
		i.BrandId					as 'BrandId',
				
		i.CategoryName				as 'CategoryName',

		-- Позиция
		i.Quantity					as 'Quantity',
		i.Discount					as 'Discount',
		i.FrozenPriceWithDiscount	as 'FrozenPriceWithDiscount'


	from BQOrderItemsLastData i
	where
		i.OrderId = @OrderId

end
