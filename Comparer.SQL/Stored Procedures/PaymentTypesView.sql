create proc PaymentTypesView as
begin

	select 
		ID, TITLE, DESCRIPTION, ADAPTER, PRICE, PRICE_ORIGINAL, DISABLED, 
		MIN_ORDER_SUM, Max_Order_Sum, SORT_ID, 
		IS_ACTIVE, IsDeleeted, SourceID, IsOld
	from PaymentTypes
	order by TITLE

end
