create proc SyncOrderStatusView 
(
	@OrderId		uniqueidentifier		-- Идентификатор заказа
) as
begin
	
	select 
		-- Информация для обмена
		so.PublicId				as 'PublicId',
		-- Заказ
		o.Status				as 'Status',
		o.PUBLICNUMBER			as 'PublicNumber',
		o.DISPATCHNUMBER		as 'DispatchNumber',
		-- Сайт
		s.ID					as 'SiteId',
		s.NAME					as 'SiteName',
		-- Причина возврата
		orr.ReasonId			as 'CancelReasonId',
		orr.AnotherReason		as 'Message'
	from CLIENTORDERS o 
		join ClientOrdersSync so on so.OrderId = o.ID
		join SITES s on s.ID = o.SITEID
		left join OrderReturnReasons orr on orr.OrderId = o.Id 
	where 
		o.ID = @OrderId 
	
end
