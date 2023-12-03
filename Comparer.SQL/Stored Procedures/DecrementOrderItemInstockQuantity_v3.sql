create proc DecrementOrderItemInstockQuantity_v3 
(
	@ProductId		uniqueidentifier,
	@Quantity		int
) as
begin

	declare 
		@InstockQuantity	int

	-- Создаем курсор
	declare decItemsCursor cursor for
	select 
		i.InstockQuantity
	from 
		#ordersItemsForCorrectInstockQuantity i
	where 
		i.ProductId = @ProductId and 
		i.InstockQuantity > 0
	order by 
		i.StatusPriority desc, i.OrderPriority desc

	open decItemsCursor

	fetch next from decItemsCursor into @InstockQuantity

	while @@fetch_status = 0
	begin
			
		-- Если "зарезервированные" остатки под данную позицию <= недостающему количеству
		if @InstockQuantity <= @Quantity begin

			-- Обновляем "зарезервированные" остатки для данной позиции 				
			update #ordersItemsForCorrectInstockQuantity 
			set 
				InstockQuantity		= 0,
				DopInstockQuantity	= -@InstockQuantity
			where 
				current of decItemsCursor

			-- Уменьшаем недостающее количество
			select @Quantity = @Quantity - @InstockQuantity

		end else begin
				
			-- Обновляем "зарезервированные" остатки для данной позиции 				
			update #ordersItemsForCorrectInstockQuantity 
			set 
				InstockQuantity		= InstockQuantity - @Quantity,
				DopInstockQuantity	= -@Quantity
			where 
				current of decItemsCursor

			-- Уменьшаем недостающее количество
			select @Quantity = 0

		end
		
		fetch next from decItemsCursor into @InstockQuantity
			
	end

	close decItemsCursor
	deallocate decItemsCursor

end
