create proc AutoCorrectOrdersReserves_v3 
(
	@ErrorMes		nvarchar(4000) out	-- Сообщение об ошибках
) as
begin

	set @ErrorMes = ''
	set nocount on

	-- Если запущен пересчет цен, то выходим из процедуры
	/*if exists(select 1 from ActiveProcesses ap where ap.TypeId = 1) begin
		set @ErrorMes = 'Авто корректировка отложена потому что запущен процесс пересчета цен!'
		return 0
	end*/

	-- Временная таблица для товаров, для которых необходимо выполнить "перерезервирование"
	create table #productsForCorrectOrdersReserves
	(
		Id		uniqueidentifier		not null
		primary key (Id)
	)
	-- Временная таблица для номеров Заданий на закупку, 
	-- по которым необходимо выполнить "перерезервирование" товарных позиций по заказам
	create table #purchaseTaskCodesForCorrectOrdersInstocQuantity 
	(
		Code	bigint		not null,
		primary key (Code)
	)
	-- Временная таблица для номеров Заказов клиентам, по которым выполнена отгрузка
	create table #orderNumbersForCorrectOrdersInstocQuantity 
	(
		Number		int		not null,
		primary key (Number)
	)

	declare 
		@resValue	int				= -1, 
		@err		nvarchar(255)	= ''

	begin try

		-- Обновляем пассивные резервы
		exec @resValue = ResetPassiveReserveStock_v3 @err out
		if @resValue = 1 begin
			set @ErrorMes = @err
			return 1
		end

		-- Проверяем артикулы, под которые должны удерживаться активные резервы
		insert #productsForCorrectOrdersReserves (Id)
		select distinct p.ProductId
		from 
		(
			select 
				c.PRODUCTID as 'ProductId'
			from 
				CLIENTORDERS o
				join CLIENTORDERSCONTENT c on o.ID = c.CLIENTORDERID
			where 
				o.STATUS = 2
				and o.PACKED = 0
				and o.NotUseInReserveProc = 0
				and c.NotUseInReserveProc = 0
				--and c.PRODUCTID = 'FC20685A-9736-4511-ADBB-0EFD1CEF88FA'
			union
			-- Заказы в статусах "Ожидает ответа" и "Ожидает предоплаты"
			select 
				c.PRODUCTID as 'ProductId'
			from 
				CLIENTORDERS o 
				join CLIENTORDERSCONTENT c on o.ID = c.CLIENTORDERID 
			where
				o.STATUS in (7, 8) 
				and o.PACKED = 0 
				and o.NotUseInReserveProc = 0
				and c.NotUseInReserveProc = 0
				and isnull(c.STOCK_QUANTITY, 0) > 0
				--and c.PRODUCTID = 'FC20685A-9736-4511-ADBB-0EFD1CEF88FA'
		) p

		-- Проверяем, есть ли товары, котороые нужно резервировать
		if exists (select 1 from #productsForCorrectOrdersReserves) begin

			-- Временная таблица товаров, для которых необходимо сбросить активные резервы
			create table #productsForReservesReset
			(
				Id		uniqueidentifier		not null
				primary key (Id)
			)

			insert #productsForReservesReset (Id)
			select 
				r.ProductId
			from 
				WarehouseProductReserves r
				left join #productsForCorrectOrdersReserves p on p.Id = r.ProductId
			where 
				r.WarehouseId = 1	-- Розничный склад
				and p.Id is null 
				and r.ReserveStock is not null
			
			-- Если есть товары, для которых нужно сбросить активные резервы
			if exists (select 1 from #productsForReservesReset) begin

				-- Сбрасываем активные резервы для товаров, которые не попадают под активные заказы
				update r
				set 
					r.ReserveStock = null
				from 
					WarehouseProductReserves r
					join #productsForReservesReset p on p.Id = r.ProductId
				where 
					r.WarehouseId = 1	-- Розничный склад

				-- Выполняем корректировку сводных активных резервов по витринам
				update s
				set 
					s.ReserveStock = l.Reserves
				from 
					(
						select
							l.SiteId, r.ProductId, sum(isnull(r.ReserveStock, 0)) as 'Reserves'
						from
							WarehouseProductReserves r
							join #productsForReservesReset p on p.Id = r.ProductId
							join WarehouseShowcaseLinks l on l.WarehouseId = r.WarehouseId
						where
							r.WarehouseId = 1	-- Розничный склад
							and l.IsActive = 1
						group by 
							l.SiteId, r.ProductId
					) l
					join ShowcaseProductsStock s on s.SiteId = l.SiteId and s.ProductId = l.ProductId
									

			end

			-- Перерезервирование
			exec @resValue = CorrectOrdersInstockQuantityForSkus_v3 5, @err out
			if @resValue = 1 begin
				set @ErrorMes = @err
				return 1
			end

		end

		return 0

	end try
	begin catch 
		set @ErrorMes = error_message()
		return 1
	end catch 

end
