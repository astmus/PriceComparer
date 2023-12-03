create proc UTMovingRozlivDocument 
(
	@PublicId			uniqueidentifier,		-- Идентификатор обмена
	-- Выходные параметры
	@ErrorMes nvarchar(4000) out				-- Сообщение об ошибках
) as
begin
	
	set @ErrorMes = ''
	set nocount on

	if not exists (select 1 from RozlivUtDocuments where PublicId = @PublicId and ConfirmedByUt = 0)
		return 0

	declare @DocId		int							-- Идентификатор документа
	declare @OrderId	uniqueidentifier			-- Идентификатор заказа

	declare @now		datetime = getdate()		-- Дата измененния
	declare @newSum		float						-- Пересчитанная сумма заказа

	-- Таблица для сохранения позиций документа
	create table #ProductIds
	(
		Id					uniqueidentifier				not null,
		OrderQuantity		int								not null,
		DocumentQuantity	int								not null,
		Quantity			int								not null,
		StockQuantity		int								not null,
		Price				float							not null,
		primary key(Id)
	)

	begin try
			
		-- Получаем идентификаторы документа и заказа
		select 
			@DocId		= r.Id, 
			@OrderId	= r.OrderId
		from 
			RozlivUtDocuments r
		where 
			r.PublicId = @PublicId		
	
	end try 
	begin catch 		
		set @ErrorMes = error_message()
		return 1
	end catch

	-- Выполняем непосредственно операции

	declare @trancount int
	select @trancount = @@trancount
	
	begin try

		if @trancount = 0
			begin transaction

		-- Проставляем документу признак "Подтвержден документов из УТ"
		update r
		set 
			r.ConfirmedByUt = 1
		from 
			RozlivUtDocuments r
		where 
			r.PublicId = @PublicId

		-- Получаем сумму заказа до изменения
		select 
			@newSum = o.FROZENSUM
		from
			CLIENTORDERS o
		where 
			o.ID = @OrderId

		-- Заполняем временную таблицу товарами проходящими в документе
		insert #ProductIds (Id, OrderQuantity, DocumentQuantity, Quantity, StockQuantity, Price)
		select 
			coc.ID, 
			coc.QUANTITY, 
			r.Quantity,
			coc.QUANTITY - r.Quantity,
			iif((coc.STOCK_QUANTITY - r.Quantity) > 0, (coc.STOCK_QUANTITY - r.Quantity), 0),
			coc.FROZENRETAILPRICE
		from 
			CLIENTORDERSCONTENT coc
			join RozlivUtDocumentItems r on r.ProductId = coc.PRODUCTID
		where 
			coc.CLIENTORDERID = @OrderId and
			r.DocId = @DocId 

		-- Если вдруг не удалось определить ни одной товарной позиции
		if not exists (select 1 from #ProductIds) begin
			if @trancount = 0
				commit transaction
			return 0
		end

		-- Выполняем проверку есть ли полностью обеспеченные товары в заказе
		if exists (select 1 from #ProductIds where Quantity = 0) begin

			-- Удаляем товары в заказе
			delete 
				CLIENTORDERSCONTENT  
			where 
				ID in 
				(
					select 
						p.Id 
					from 
						#ProductIds p
					where 
						Quantity = 0
				)

		end

		-- Выполняем проверку есть ли не полностью обеспеченные товары в заказе
		if exists (select 1 from #ProductIds where Quantity > 0) begin

			-- Выполняем корректировку позиций заказа
			update coc
			set 
				coc.QUANTITY = p.Quantity,
				coc.STOCK_QUANTITY = p.StockQuantity,
				coc.STOCK_QUANTITY_DATE = @now
			from
				#ProductIds p
				join CLIENTORDERSCONTENT coc on coc.ID = p.Id
			where 
				p.Quantity > 0

		end
			
		-- Выполняем пересчет суммы заказа
		set @newSum = @newSum - (select sum(p.DocumentQuantity * p.Price) from #ProductIds p)

		-- Выполняем корректировку даты изменения и суммы заказа 
		update co
		set 
			co.CHANGEDATE	= @now,
			co.FROZENSUM	= @newSum
		from 
			CLIENTORDERS co
		where 
			co.ID = @OrderId
		
		-- Проверяем если в заказе не осталось позиций изменяем статус на "Получен клиентом"
		if not exists (select 1 from CLIENTORDERSCONTENT where CLIENTORDERID = @OrderId) begin
			
			-- Меняем статус заказа на "Получен клиентом"
			update o
			set 
				o.STATUS = 5 				
			from 
				CLIENTORDERS o
			where 
				o.ID = @OrderId

			-- Добавляем запись в историю изменения статусов
			insert ORDERSSTATUSHISTORY (CLIENTORDER, STATUS, STATUSDATE, EMAIL, AUTHOR)			
			values(@OrderId, 5, getdate(), null, 'WMSBot')

			-- Добавляем действия пользователей			
			insert USERACTIONS (USERID, 
								OBJECTTYPE, ObjectId, 
								ACTIONTYPE, 
								PARAMS, 
								ActionInfo)
			select '86C6A872-1187-4C8B-B382-8DBD917837EC', 
					9, lower(cast(o.ID as varchar(36))),
					2, 
				   'OrderID=' + lower(cast(o.ID as varchar(36))) + 
				   ';Номер заказа=' + case when o.PUBLICNUMBER = '' then cast(o.NUMBER as varchar(10)) else o.PUBLICNUMBER end + 
				   ';Статус=Получен клиентом' + 
				   ';Итого за заказ=' + cast(o.FROZENSUM as varchar(36)) + 
				   ';',
				   null
			from 
				CLIENTORDERS o 
			where 
				o.ID = @OrderId

		end else begin

			-- Добавляем действия пользователей			
			insert USERACTIONS (USERID, 
								OBJECTTYPE, ObjectId, 
								ACTIONTYPE, 
								PARAMS, 
								ActionInfo)
			select '86C6A872-1187-4C8B-B382-8DBD917837EC', 
					9, lower(cast(o.ID as varchar(36))),
					2, 
				   'OrderID=' + lower(cast(o.ID as varchar(36))) + 
				   ';Номер заказа=' + case when o.PUBLICNUMBER = '' then cast(o.NUMBER as varchar(10)) else o.PUBLICNUMBER end + 
				   ';Итого за заказ=' + cast(o.FROZENSUM as varchar(36)) + 
				   ';',
				   null
			from 
				CLIENTORDERS o 
			where 
				o.ID = @OrderId

		end
		
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
