create proc IncrementOrderItemInstockQuantity_v3 
(
	@ProductId			uniqueidentifier,	-- Идентификатор товара
	@IncQuantity		int,				-- Кол-во товаров для распределения
	@Mode				int					-- Режим распределения
											-- 1 - Приемка
											-- 2 - Распределение свободных остатков
) as
begin

	declare 
		@OrderPriority			varchar(50), 
		@Number					int, 
		@Sku					int, 
		@IsGift					bit, 
		@InstockQuantity		int, 
		@Quantity				int, 
		@PurchaseQuantity		int

	-- Объявляем таблицу для закупленных записей
	create table #itemsForDistribution
	(
		OrderId				uniqueidentifier	not null,					-- Идентификатор заказа
		Number				int					not null,					-- Номер заказа
		ProductId			uniqueidentifier	not null,					-- Идентификатор товара
		Sku					int					not null,					-- Артикул товара
		IsGift				bit					not null,					-- Подарок
		Quantity			int					not null,					-- Количество товарных позиций по заказу
		CreatedDate			datetime			not null,					-- Дата создания заказа
		OrderPriority		varchar(50)			not null,					-- Приоритет по заказу в целом
		StatusPriority		tinyint				not null,					-- Приоритет по статусу заказа (2 или 4 = 1, 7 или 8 = 2)
		PurchaseQuantity	int					not null,					-- Количество товарных позиций, закупленных под заказ позиций
		InstockQuantity		int					not null,					-- Количество товарных позиций, обеспеченное складом (общее)
		DopInstockQuantity	int					not null default (0),		-- Количество товарных позиций, обеспеченное складом (в рамках текущего распределения)
		primary key (OrderId, ProductId, IsGift)
	)

	-----------------------------------------
	-- Если распределение после Приемки
	-----------------------------------------
	if @Mode = 1 begin

		declare
			@distributionQuantity		int		= 0		-- Кол-во, которое ожидается по конкретному заданию на закупку
			
		-- Заполняем таблицу для распределения
		insert #itemsForDistribution (OrderId, ProductId, CreatedDate, OrderPriority, StatusPriority, Number, Sku, IsGift, Quantity, PurchaseQuantity, InstockQuantity)
		select 
			i.OrderId, i.ProductId, i.CreatedDate, i.OrderPriority, i.StatusPriority, i.Number, i.Sku, i.IsGift, i.Quantity, i.PurchaseQuantity, i.InstockQuantity
		from 
			#ordersItemsForCorrectInstockQuantity i
		where 
			i.Quantity > i.InstockQuantity and 
			i.ProductId = @ProductId

		print '@incQuantity = ' + cast(@IncQuantity as varchar(100))

		-- Если есть закупленные позиции, которые еще не обеспечены складом
		if exists (select 1 from #itemsForDistribution) begin

			-- Если распределяемый товар - это отливант
			-- изменяем приоритет по дате создания
			if exists (select 1 from #otlivants o where o.ProductId = @ProductId)
			begin

				update i
				set 
					i.OrderPriority = 
						right('0000' + cast(year(i.CreatedDate) as varchar(4)), 4) +
						right('00' + cast(month(i.CreatedDate) as varchar(2)), 2) +
						right('00' + cast(day(i.CreatedDate) as varchar(2)), 2) +
						right('00' + cast(datepart(hour, i.CreatedDate) as varchar(2)), 2) +
						right('00' + cast(datepart(minute, i.CreatedDate) as varchar(2)), 2) +
						right('00' + cast(datepart(second, i.CreatedDate) as varchar(2)), 2)
				from
					#itemsForDistribution i

			end

			-- Создаем курсор
			declare incItemsCursor cursor for
			select 
				Number, Sku, InstockQuantity, Quantity
			from 
				#itemsForDistribution
			where 
				ProductId = @ProductId
			order by 
				StatusPriority, OrderPriority
			
			open incItemsCursor

			fetch next from incItemsCursor into @Number, @Sku, @InstockQuantity, @Quantity

			while @@fetch_status = 0
			begin
			
				select 
					@distributionQuantity = d.Quantity 
				from 
					#purchaseDistributionSkus d 
				where 
					d.Number = @Number and 
					d.Sku = @Sku

				if @distributionQuantity is null
					set @distributionQuantity = 0

				print '@distributionQuantity = ' + cast(@distributionQuantity as varchar(100))

				-- Если под данный заказ ожидается поступления по закупке
				if @distributionQuantity > 0 begin

					-- Если по закупке ожидается больше, чем нужно под заказ
					if @distributionQuantity > (@Quantity - @InstockQuantity) begin

						-- Если "свободных" остатков недостаточно под данную позицию
						if (@Quantity - @InstockQuantity) > @IncQuantity begin

							-- Обновляем "зарезервированные" остатки для данной позиции 				
							update #itemsForDistribution 
							set 
								InstockQuantity		= InstockQuantity + @IncQuantity,
								PurchaseQuantity	= PurchaseQuantity - @IncQuantity,	-- уменьшаем кол-во ожидаемое после закупки (приемки)
								DopInstockQuantity	= @IncQuantity
							where 
								current of incItemsCursor
						
							-- Сбрасываем "свободные" остатки в ноль
							select @IncQuantity = 0

						end else begin
				
							-- Обновляем "зарезервированные" остатки для данной позиции 				
							update #itemsForDistribution 
							set 
								InstockQuantity		= Quantity,
								PurchaseQuantity	= 0,
								DopInstockQuantity	= Quantity - InstockQuantity
							where 
								current of incItemsCursor

							-- Уменьшаем "свободные" остатки
							select @IncQuantity = @IncQuantity - (@Quantity - @InstockQuantity)

						end

					end else begin

						-- Если "свободных" остатков недостаточно под данную позицию
						if @distributionQuantity > @IncQuantity begin

							-- Обновляем "зарезервированные" остатки для данной позиции 				
							update #itemsForDistribution 
							set 
								InstockQuantity		= InstockQuantity + @IncQuantity,
								PurchaseQuantity	= PurchaseQuantity - @IncQuantity,
								DopInstockQuantity	= @IncQuantity
							where 
								current of incItemsCursor

							-- Сбрасываем "свободные" остатки в ноль
							select @IncQuantity = 0

						end else begin
				
							-- Обновляем "зарезервированные" остатки для данной позиции 				
							update #itemsForDistribution 
							set 
								InstockQuantity		= InstockQuantity + @distributionQuantity,
								PurchaseQuantity	= PurchaseQuantity - @distributionQuantity,
								DopInstockQuantity	= @distributionQuantity
							where 
								current of incItemsCursor

							-- Уменьшаем "свободные" остатки
							select @IncQuantity = @IncQuantity - @distributionQuantity

						end

					end

				end
		
				fetch next from incItemsCursor into @Number, @Sku, @InstockQuantity, @Quantity
			
			end

			close incItemsCursor
			deallocate incItemsCursor

			-- Обновляем таблицу #ordersItemsForCorrectInstockQuantity
			update i
			set 
				i.InstockQuantity		= p.InstockQuantity,
				i.DopInstockQuantity	= p.DopInstockQuantity
			from 
				#ordersItemsForCorrectInstockQuantity i 
				join #itemsForDistribution p on p.Number = i.Number and p.Sku = i.Sku and i.IsGift = p.IsGift

		end

	end 
	-----------------------------------------
	-- Если распределение свободных остатков
	-----------------------------------------
	else begin
		
		-- Заполняем таблицу для распределения
		insert #itemsForDistribution (OrderId, ProductId, CreatedDate, OrderPriority, StatusPriority, Number, Sku, IsGift, Quantity, PurchaseQuantity, InstockQuantity)
		select 
			i.OrderId, i.ProductId, i.CreatedDate, i.OrderPriority, i.StatusPriority, i.Number, i.Sku, i.IsGift, i.Quantity, i.PurchaseQuantity, i.InstockQuantity
		from 
			#ordersItemsForCorrectInstockQuantity i
		where 
			i.Quantity > i.InstockQuantity and
			i.ProductId = @ProductId

		-- Если есть заказы для распределения
		if exists (select 1 from #itemsForDistribution) begin

			-- Если распределяемый товар - это отливант
			-- изменяем приоритет по дате создания
			if exists (select 1 from #otlivants o where o.ProductId = @ProductId)
			begin

				update i
				set 
					i.OrderPriority = 
						right('0000' + cast(year(i.CreatedDate) as varchar(4)), 4) +
						right('00' + cast(month(i.CreatedDate) as varchar(4)), 2) +
						right('00' + cast(day(i.CreatedDate) as varchar(2)), 2) +
						right('00' + cast(datepart(hour, i.CreatedDate) as varchar(2)), 2) +
						right('00' + cast(datepart(minute, i.CreatedDate) as varchar(2)), 2) +
						right('00' + cast(datepart(second, i.CreatedDate) as varchar(2)), 2)
				from
					#itemsForDistribution i

			end

			-- Создаем курсор
			declare incFreeItemsCursor cursor for
			select 
				OrderPriority, Number, Sku, InstockQuantity, Quantity
			from 
				#itemsForDistribution
			where 
				ProductId = @ProductId and 
				(Quantity - InstockQuantity) > 0
			order by	
				StatusPriority, OrderPriority
			
			-- Открываем курсор
			open incFreeItemsCursor

			fetch next from incFreeItemsCursor into @OrderPriority, @Number, @Sku, @InstockQuantity, @Quantity			
			while @@fetch_status = 0
			begin

				-- Если "свободных" остатков недостаточно под данную позицию
				if (@Quantity - @InstockQuantity) > @IncQuantity begin

					-- Обновляем "зарезервированные" остатки для данной позиции 				
					update #itemsForDistribution 
					set 
						InstockQuantity			= InstockQuantity + @IncQuantity,
						DopInstockQuantity		= @IncQuantity
					where 
						current of incFreeItemsCursor

					-- Сбрасываем "свободные" остатки в ноль
					select @IncQuantity = 0

				end else begin
				
					-- Обновляем "зарезервированные" остатки для данной позиции 				
					update #itemsForDistribution 
					set 
						InstockQuantity			= Quantity,
						DopInstockQuantity		= Quantity - InstockQuantity
					where 
						current of incFreeItemsCursor

					-- Уменьшаем "свободные" остатки
					select @IncQuantity = @IncQuantity - (@Quantity - @InstockQuantity)

				end
		
				fetch next from incFreeItemsCursor into @OrderPriority, @Number, @Sku, @InstockQuantity, @Quantity
			
			end
		
			close incFreeItemsCursor
			deallocate incFreeItemsCursor

			-- Обновляем таблицу #ordersItemsForCorrectInstockQuantity
			update i
			set 
				i.InstockQuantity		= p.InstockQuantity,
				i.DopInstockQuantity	= p.DopInstockQuantity
			from 
				#ordersItemsForCorrectInstockQuantity i 
				join #itemsForDistribution p on p.Number = i.Number and p.Sku = i.Sku and i.IsGift = p.IsGift

		end

	end

	drop table #itemsForDistribution

end
