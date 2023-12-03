create proc RusPostAccountsOrdersProportionView as
begin

	select o.AccountId, count(*) as 'OrdersCount'
	from ApiDeliveryServiceOrders o
		join ApiDeliveryServicesAccounts a on o.AccountId = a.Id		
		join CLIENTORDERS ord on ord.ID = o.InnerId and ord.PAIDSUM < ord.FROZENSUM	-- НП
	where
		a.ServiceId = 4
		--and a.ApiVersion = 2
		and cast(o.CreatedDate as date) = cast(getdate() as date)
	group by 
		o.AccountId

end
