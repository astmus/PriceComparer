create proc SUZOrderDataMatrixesSetAsPrinted
(
	@AuthorId		uniqueidentifier,		-- Идентификатор автора
	-- Out-параметры
	@ErrorMes		nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on;

	set @ErrorMes = ''

	-- Информация о заказах, для которых произвелась печать этикеток
	create table #ordersInfo
	(
		OrderId				int					not null,
		ItemId				int					not null,
		DMId				int					not null,
		DataMatrix			nvarchar(128)		not null,
		OrderActiveState	bit					not null default (1),
		ItemActiveState		bit					not null default (1),
		Quantity			int					not null,
		PrintedQuantity		int					not null,
		PrintingQuantity	int					not null default (0),
		primary key (OrderId, ItemId, DMId)
	)

	-- Подготавливаем данные
	begin try

		-- Собираем информацию о заказах, позициях и маркировках
		insert #ordersInfo (OrderId, ItemId, DMId, Quantity, PrintedQuantity, DataMatrix)
		select
			o.Id, i.Id, dm.Id, i.Quantity, i.PrintedQuantity, dm.DataMatrix
		from
			#SUZDataMatrixes t
				join SUZOrderItemDataMatrixes dm on t.DataMatrix = dm.DataMatrix and dm.IsPrinted = 0
				join SUZOrderItems i on i.Id = dm.ItemId and i.IsActive = 1
				join SUZOrders o on o.Id = i.OrderId and o.IsActive = 1 and o.StatusId = 1

		if not exists (select 1 from #ordersInfo) begin

			set @ErrorMes = 'Не удалось определить заказы для преданной маркировки!';
			return 0;

		end
		
		-- Обновляем состояние активности у позиции
		update oi
		set 
			oi.ItemActiveState = 
				case 
					when (t.PrintingCount + oi.PrintedQuantity) < oi.Quantity then cast(1 as bit)
					else cast(0 as bit)
				end,
			oi.PrintingQuantity = t.PrintingCount
		from #ordersInfo oi
			join
			(
				select 
					-- Количество маркировок, которое необходимо отметить как распечатанные
					i.ItemId, count(i.DataMatrix) as 'PrintingCount'	
				from
					#ordersInfo i
				group by
					i.ItemId
			) t on t.ItemId = oi.ItemId

		-- Обновляем состояние активности у заказа
		update oi
		set 
			oi.OrderActiveState = case 
									when isnull(t.ActiveCount, 0) = 0 then cast(0 as bit)
									else cast(1 as bit)
								end
		from #ordersInfo oi
			left join
			(
				select 
					o.Id, sum(iif(i.IsActive = 1, 1, 0)) as 'ActiveCount'
				from
					(
						select distinct OrderId from #ordersInfo
					) oi
						join SUZOrders o on o.Id = oi.OrderId
						join SUZOrderItems i on i.OrderId = o.Id
						left join 
						(
							select distinct ItemId from #ordersInfo where ItemActiveState = 0
						) ii on ii.ItemId = i.Id
				where
					ii.ItemId is null
				group by
					o.Id
			) t on t.Id = oi.OrderId

			-- DEBUG
			select * from #ordersInfo
			-- DEBUG

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch


	declare @trancount int
	select @trancount = @@trancount

	begin try

		if @trancount = 0
			begin transaction

		-- Обновляем состояние активности у заказов
		update o
		set 
			o.IsActive		= 0,
			o.ClosedDate	= getdate(),
			o.MustBeClosed	= 1
		from 
			SUZOrders o
		where
			o.Id in
			(
				select distinct i.OrderId from #ordersInfo i where i.OrderActiveState = 0
			)

		-- Обновляем состояние активности
		-- и кол-во распечатанных маркировок
		-- у позиций, которые уже не активны
		update i
		set 
			i.IsActive			= 0,
			i.PrintedQuantity	= i.Quantity
		from 
			SUZOrderItems i
		where
			i.Id in
			(
				select distinct i.ItemId from #ordersInfo i where i.ItemActiveState = 0
			)

		-- Обновляем кол-во распечатанных маркировок 
		-- у позиций, которые еще активны
		update i
		set 
			i.PrintedQuantity = i.PrintedQuantity + oi.PrintingQuantity
		from 
			SUZOrderItems i
			join 
			(
				select distinct i.ItemId, i.PrintingQuantity from #ordersInfo i where i.ItemActiveState = 1
			) oi on oi.ItemId = i.Id

		-- Обновляем признак печати у маркировок
		update dm
		set
			dm.IsPrinted	= 1,
			dm.PrintedDate	= getdate()
		from
			SUZOrderItemDataMatrixes dm
		where
			dm.Id in
			(
				select distinct i.DMId from #ordersInfo i
			)
		
		if @trancount = 0
			commit transaction

		return 0

	end try
	begin catch		
		if @trancount = 0
			rollback transaction
		set @ErrorMes = error_message()
		return 1
	end catch

end
