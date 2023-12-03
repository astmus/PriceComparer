create proc DecrementOrdersInstockQuantity_v3 as
begin

	declare 
		@ProductId		uniqueidentifier, 
		@Quantity		int
	
	declare decCursor cursor for
	select 
		i.ProductId, i.Quantity
	from 
		#productsForCorrectOrdersInstockQuantity i
	order by 
		i.ProductId

	open decCursor  

	fetch next from decCursor into @ProductId, @Quantity

	while @@fetch_status = 0
	begin

		exec DecrementOrderItemInstockQuantity_v3 @ProductId, @Quantity
		
		fetch next from decCursor into @ProductId, @Quantity
	end

	close decCursor
	deallocate decCursor

	return 0

end
