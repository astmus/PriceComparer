create proc UTExportOrderInvoiceSummaryBegin (@SessionId bigint out) as
begin

	set nocount on
	declare @trancount int
	select @trancount = @@TRANCOUNT
	set @SessionId = 0

	-- Таблица для сохранения изменившихся и созданных объектов
	declare @objTable table(
		Id				bigint					not null,						-- Уникальный идентификатор
		InvoicePublicId uniqueidentifier		not null,						-- Внеший Id накладной
		OrderId			uniqueidentifier		not null,						-- Внутренний номер заказа

		primary key(Id)
	)

	begin try

		if @trancount = 0
			begin transaction
		
		-- "Захватываем" таблицу ExportOrderInvoiceSummary и запоминаем список товарных позиций
		insert @objTable (Id, InvoicePublicId, OrderId)
		select Id, InvoicePublicId, OrderId
		from ExportOrderInvoiceSummary

		-- Если изменившиеся или созданные объекты есть
		if exists(select 1 from @objTable) begin
									
			-- Создаем новую сессию		
			insert ExportOrderInvoiceSummarySessions(CreatedDate) values(getdate())

			-- Запоминаем идентификатор сессии
			set @SessionId = @@IDENTITY

			-- Сохраняем записи
			insert ExportOrderInvoiceSummarySessionItems (SessionId, Id)
			select @SessionId, Id from @objTable

			select @SessionId as 'SessionId'

			-- Выгружаем Заказы 
			select
				-- Накладная + черновик
				ed.PublicGuid								as 'Id', 
				ed.OrderId									as 'OrderId',
				e.Number									as 'InvoiceNumber',
				e.DocCreatedDate							as 'DocCreatedDate',
				case e.DocStatus
					when 5 then cast(1 as bit)
					else cast (0  as bit)
				end											as 'Deleted',

				-- Заказ
				co.PUBLICNUMBER								as 'OrderPublicNumber',

				-- Доставка и оплата
				isnull(od.DeliveryKindId, 0)				as 'DeliveryKindId',
				isnull(od.DeliveryServiceId, 0)				as 'DeliveryServiceId',
				convert(int, isnull(co.PAYMENTKIND, 0))		as 'PaymentKindId',

				-- Клиент
				case co.CLIENTID
					when '498EF36F-4211-4B72-8A40-BAE4175AEEA5' then 'BA11349E-5EA0-465D-904A-61D6E381E6DC'
					when '79CD61D2-988A-471E-B73F-71EBC63BB0AB' then 'BA11349E-5EA0-465D-904A-61D6E381E6DC'
					when 'BA11349E-5EA0-465D-904A-61D6E381E6DC' then 'BA11349E-5EA0-465D-904A-61D6E381E6DC'
					else co.CLIENTID
				end											as 'ClientId'


			from @objTable chg 
			 join EdoDrafts ed  with(nolock) on ed.OrderId = chg.OrderId and ed.EntityId = chg.InvoicePublicId
			 join EdoInvoices e with(nolock) on e.PublicId = cast(ed.EntityId as nvarchar(255))
			 join CLIENTORDERS co with (nolock) on ed.OrderId = co.ID
			 left join ClientOrdersDelivery od with(nolock) on od.OrderId = chg.OrderId
			order by OrderId
				
			-- Выгружаем позиции заказов
			select 
				p.Id						as 'ProductId',
				cast(i.Quantity as int)		as 'Quantity',
				i.Price						as 'Price',
				i.Total						as 'SubTotalWithoutTax',
				i.Tax						as 'Tax',
				'20'						as 'TaxRate',
				p.NeedDataMatrix			as 'NeedDataMatrix',
				chg.OrderId					as 'OrderId'
			from @objTable chg 
			    join EdoInvoices d with(nolock) on d.PublicId = cast(chg.InvoicePublicId as nvarchar(255))
				join EdoInvoiceItems i with(nolock) on i.InvoiceId = d.Id	
				join Products p on p.ID = i.ProductId	
			order by 
				OrderId, ProductId						
						
		end

		if @trancount = 0
			commit transaction
			
		return 0
	end try 
	begin catch 
		if @trancount = 0
			rollback transaction

		return 1
	end catch 
	
end
