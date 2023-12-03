create proc PutOrdersForWMS_v3 as
begin

	set nocount on

	declare 
		@now				datetime = getdate()
			
	declare
		@today				int = datepart(weekday, @now),		-- Текущий день недели
		@dayCount			int = 1	-- Кол-во дней, для которого выполняем проверку
									-- по умолчанию следующий день

	-- Если суббота, то проверять заказы будем до понедельника до 14:00
	if @today = 6 set @dayCount = 2

	declare 
		@calcDate			datetime = dateadd(hh,14,cast(dateadd(dd,@dayCount,cast(@now as date)) as datetime))

	declare @trancount int
	select @trancount = @@TRANCOUNT
	
	begin try

		if @trancount = 0
			begin transaction
	
		-- 1. Создаем/обновляем документы "Заказ на отгрузку" -----------------------------------------

		-- Архивируем устаревшие документы в таблице WmsShipmentOrderDocuments
		insert WmsShipmentOrderDocumentsArchive (Id, WarehouseId, PublicId, ClientId, Number, DocStatus, WmsCreateDate, ShipmentDate, ShipmentDirection, RouteId, 
												 IsPartial, IsShipped, IsDeleted, Comments, Operation, AuthorId, CreateDate, ReportDate)	
		select d.Id, d.WarehouseId, d.PublicId, d.ClientId, d.Number, d.DocStatus, d.WmsCreateDate, d.ShipmentDate, d.ShipmentDirection, d.RouteId, 
			   d.IsPartial, d.IsShipped, d.IsDeleted, d.Comments, d.Operation, d.AuthorId, d.CreateDate, d.ReportDate
		from #orderIdsForExport o
			join WmsShipmentOrderDocuments d on d.PublicId = o.OrderId
			
		-- Архивируем Товарные позиции по устаревшему Документу
		insert WmsShipmentOrderDocumentsItemsArchive (Id, DocId, ProductId, Sku, Quantity, Price, CreateDate)
		select i.Id, i.DocId, i.ProductId, i.Sku, i.Quantity, i.Price, i.CreateDate
		from #orderIdsForExport o
			join WmsShipmentOrderDocuments d on d.PublicId = o.OrderId
			join WmsShipmentOrderDocumentsItems i on d.Id = i.DocId
		
		-- Закомментировал 11.10.2021	  	
		-- Объявляем таблицу для сохранения ранее выгруженных позиций по частичным заказам		
		/*declare @partialItems table (
			Id					bigint					not null,						-- Идентификатор записи
			DocId				bigint 					not null,						-- Идентификатор документа
			ProductId			uniqueidentifier		not null,						-- Идентификатор товара
			Sku					int						not null,						-- Артикул товара
			Quantity			int						not null,						-- Количество товарных позиций			
			Price				float					not null default(0.0),			-- Стоимость товара
			CreateDate			datetime				not null default(getdate()),	-- Дата и время создания записи	
			primary key (Id)
		)
		-- Заполняем таблицу
		insert @partialItems (Id, DocId, ProductId, Sku, Quantity, Price, CreateDate)
		select i.Id, i.DocId, i.ProductId, i.Sku, i.Quantity, i.Price, i.CreateDate
		from #orderIdsForExport o
			join WmsShipmentOrderDocuments d on d.PublicId = o.OrderId and o.IsPartial = 1
			join WmsShipmentOrderDocumentsItems i on d.Id = i.DocId	and i.ProductId <> '1A36C1D1-E5BF-4D87-9035-1121E24810B1'
			left join CLIENTORDERSCONTENT c on c.CLIENTORDERID = o.OrderId and c.RETURNED = 0 and c.PRODUCTID = i.ProductId	and c.QUANTITY > 0		
		where c.PRODUCTID is not null
		*/
						
		-- Удаляем Товарные позиции по устаревшему Документу
		delete i
		from 
			#orderIdsForExport o
			join WmsShipmentOrderDocuments d on d.PublicId = o.OrderId
			join WmsShipmentOrderDocumentsItems i on d.Id = i.DocId

		-- Обновляем Документ, которые уже есть в таблице
		--declare @now datetime = getdate()
		update d
		set d.Operation = 2,
			d.IsPartial = e.IsPartial,
			d.ReportDate = @now,
			d.ClientId = case 
				when o.CLIENTID in ('498EF36F-4211-4B72-8A40-BAE4175AEEA5','79CD61D2-988A-471E-B73F-71EBC63BB0AB','BA11349E-5EA0-465D-904A-61D6E381E6DC') 
					then 'BA11349E-5EA0-465D-904A-61D6E381E6DC'
				when o.CLIENTID = '5B0F388B-5131-4E50-99AB-EF643F0A8D90'
					then '5B0F388B-5131-4E50-99AB-EF643F0A8D90'
				when o.CLIENTID = '459723EB-F12A-44C6-85B0-BF0B7765AD21'
					then '459723EB-F12A-44C6-85B0-BF0B7765AD21'
				else o.CLIENTID
			end,
			d.ShipmentDate = isnull(o.ExpectedDate, @now),
			d.DocStatus = case 
							when d.DocStatus = 10 then 10
							when o.STATUS in (3,6) then 11
							when o.STATUS in (7,8) then 9
							else d.DocStatus
						end,
			d.ShipmentDirection =
				case --o.DELIVERYKIND
					-- курьеры
					when o.DELIVERYKIND in (1, 2, 3, 4, 6, 8, 18, 30, 32, 33, 47) then 
						case
							-- Сервис DalliService
							when cod.DeliveryServiceId = 3 then 2
							-- Сервис Randewoo
							when cod.DeliveryServiceId = 5 then 1
							-- Сервис Доставка Клаб
							when cod.DeliveryServiceId = 9 then 2
							-- Сервис Л-Пост
							when cod.DeliveryServiceId = 11 then 2
							-- Сервис Logsis
							when cod.DeliveryServiceId = 13 then 2
							-- Сервис Интеграл
							when cod.DeliveryServiceId = 14 then 2
							-- Сервис Randewoo
							else 1
						end
					when o.DELIVERYKIND in (7, 19) then 2
					when o.DELIVERYKIND = 5 then 2
					when o.DELIVERYKIND = 12 then 2
					when o.DELIVERYKIND = 13 then 1
					when o.DELIVERYKIND = 14 then 2
					when o.DELIVERYKIND = 48 then 2
					--when 15 then ''
					when o.DELIVERYKIND = 16 then 2
					when o.DELIVERYKIND = 17 then 2
					when o.DELIVERYKIND = 20 then 3
					-- СДЭК
					when o.DELIVERYKIND = 21 then 2
					when o.DELIVERYKIND = 22 then 2
					when o.DELIVERYKIND = 23 then 2
					when o.DELIVERYKIND = 35 then 2
					when o.DELIVERYKIND = 36 then 2
					-- Dostavka-club
					when o.DELIVERYKIND = 39 then 2
					when o.DELIVERYKIND = 40 then 2
					-- Пятерочка
					when o.DELIVERYKIND = 42 then 2
					-- 
					when o.DELIVERYKIND = 43 then 2
					when o.DELIVERYKIND = 44 then 2
					-- Л-Пост
					when o.DELIVERYKIND = 45 then 2
					when o.DELIVERYKIND = 46 then 2
					-- Yandex
					when o.DELIVERYKIND = 24 then 2
					when o.DELIVERYKIND = 25 then 2
					when o.DELIVERYKIND = 26 then 2
					when o.DELIVERYKIND = 27 then 1
					-- Goods
					when o.DELIVERYKIND = 101 then 1
					-- Беру
					when o.DELIVERYKIND = 102 then 1
					-- Boxberry
					when o.DELIVERYKIND = 50 then 2
					when o.DELIVERYKIND = 51 then 2
					-- Halva Express
					when o.DELIVERYKIND = 52 then 2
					-- Бесконтактные
					when o.DELIVERYKIND = 30 then 1
					when o.DELIVERYKIND = 31 then 2
					when o.DELIVERYKIND = 32 then 1
					when o.DELIVERYKIND = 33 then 1
					when o.DELIVERYKIND = 34 then 2
					else -1
				end,
			d.RouteId = 
				case 
					when o.CLIENTID in ('498EF36F-4211-4B72-8A40-BAE4175AEEA5','79CD61D2-988A-471E-B73F-71EBC63BB0AB','BA11349E-5EA0-465D-904A-61D6E381E6DC') -- Escentric 
						then '89aa2b93-076e-4325-9cd3-353e59c504dd' 
					when o.CLIENTID = '5B0F388B-5131-4E50-99AB-EF643F0A8D90'	-- Новикова	Новикова Александровна
						then '7a100b3d-6b76-4768-a0a3-175433785f82'
					when o.CLIENTID = '459723EB-F12A-44C6-85B0-BF0B7765AD21'	-- Тимошкова Тимошкова Александровна
						then 'e86affcc-f7c6-453b-b809-a78008f07473'
					else
						case --o.DELIVERYKIND
							-- Курьеры по Москве
							when o.DELIVERYKIND in (1, 2, 3, 4, 6, 8, 18, 30, 32, 33, 47) then
								case
									-- Сервис DalliService
									when cod.DeliveryServiceId = 3 then '38e19270-bb54-4129-978e-a87b7e1193fd'
									-- Сервис Randewoo
									when cod.DeliveryServiceId = 5 then 
										case when line.WmsRouteId is null then '00000000-0000-0000-0000-000000000000' else cast(line.WmsRouteId as varchar(36)) end
									-- Сервис Доставка Клаб
									when cod.DeliveryServiceId = 9 then '7bd02e24-bfbf-4769-aea2-cf089a1d531c'
									-- Сервис Л-Пост
									when cod.DeliveryServiceId = 11 then '218f3820-55da-47a5-a751-81acd14f7b6e'
									-- Сервис Logsis
									when cod.DeliveryServiceId = 13 then '79B6D4EC-43CC-493A-9D2D-AFE51DBCF8D1'
									-- Сервис Интеграл
									when cod.DeliveryServiceId = 14 then '3a1d49d5-9552-43b8-8bd6-537b3d7ea59d'
									-- Не определен
									else '00000000-0000-0000-0000-000000000000'
								end
							-- Нестандартная доставка
							when o.DELIVERYKIND = 13 then '21b86df1-c715-43f1-8353-fc7ead78006f'
							-- Ozon
							when o.DELIVERYKIND = 27 then '21b86df1-c715-43f1-8353-fc7ead78006f'
							-- Goods
							when o.DELIVERYKIND = 101 then '21b86df1-c715-43f1-8353-fc7ead78006f'
							-- Беру
							when o.DELIVERYKIND = 102 then '21b86df1-c715-43f1-8353-fc7ead78006f'
							-- Почта России
							when o.DELIVERYKIND = 5 then '02604e5e-ccb4-4d41-9817-9c2a2fe2a635'					
							when o.DELIVERYKIND = 48 then '02604e5e-ccb4-4d41-9817-9c2a2fe2a635'					
							-- EMS
							when o.DELIVERYKIND = 12 then '1adb74db-47b6-4fa2-857b-d7d8b074b2c5'
							when o.DELIVERYKIND = 14 then '1adb74db-47b6-4fa2-857b-d7d8b074b2c5'
							when o.DELIVERYKIND = 24 then '1adb74db-47b6-4fa2-857b-d7d8b074b2c5'
							-- PickPoint
							when o.DELIVERYKIND = 16 then '1ddc54cc-d2f3-49d4-90cd-4cc613ef7143'
							when o.DELIVERYKIND = 17 then '1ddc54cc-d2f3-49d4-90cd-4cc613ef7143'		
							when o.DELIVERYKIND = 26 then '1ddc54cc-d2f3-49d4-90cd-4cc613ef7143'
							-- СДЭК
							when o.DELIVERYKIND = 21 then '13a90ad4-d180-4938-a5c0-bb9e7af422b8'
							when o.DELIVERYKIND = 22 then '13a90ad4-d180-4938-a5c0-bb9e7af422b8'
							when o.DELIVERYKIND = 23 then '13a90ad4-d180-4938-a5c0-bb9e7af422b8'
							when o.DELIVERYKIND = 35 then '13a90ad4-d180-4938-a5c0-bb9e7af422b8'
							when o.DELIVERYKIND = 36 then '13a90ad4-d180-4938-a5c0-bb9e7af422b8'
							-- Dostavka-club
							when o.DELIVERYKIND = 39 then '7bd02e24-bfbf-4769-aea2-cf089a1d531c'
							when o.DELIVERYKIND = 40 then '7bd02e24-bfbf-4769-aea2-cf089a1d531c'
							-- Пятерочка
							when o.DELIVERYKIND = 42 then '4e178376-15ea-4bc0-bafa-4cd8ac41de0c'
							-- Л-Пост
							when o.DELIVERYKIND = 43 then '218f3820-55da-47a5-a751-81acd14f7b6e'
							when o.DELIVERYKIND = 44 then '218f3820-55da-47a5-a751-81acd14f7b6e'
							-- Yandex
							when o.DELIVERYKIND = 45 then 'ef62b92d-9567-4e42-bc34-a71c61d5c868'
							when o.DELIVERYKIND = 46 then 'ef62b92d-9567-4e42-bc34-a71c61d5c868'
							-- Dalli Service
							when o.DELIVERYKIND = 25 then '38e19270-bb54-4129-978e-a87b7e1193fd'
							-- Курьеры СПб
							when o.DELIVERYKIND in (7, 19, 31, 34) then
								case
									-- Сервис DalliService
									when cod.DeliveryServiceId = 3 then '38e19270-bb54-4129-978e-a87b7e1193fd'
									-- Сервис Доставка Клаб
									when cod.DeliveryServiceId = 9 then '7bd02e24-bfbf-4769-aea2-cf089a1d531c'
									-- Сервис Л-Пост
									when cod.DeliveryServiceId = 11 then '218f3820-55da-47a5-a751-81acd14f7b6e'
									-- Сервис Logsis
									when cod.DeliveryServiceId = 13 then '79B6D4EC-43CC-493A-9D2D-AFE51DBCF8D1'
									-- Сервис Интеграл
									when cod.DeliveryServiceId = 14 then '3a1d49d5-9552-43b8-8bd6-537b3d7ea59d'
									-- Не определен
									else '38e19270-bb54-4129-978e-a87b7e1193fd'
								end
							-- Boxberry
							when o.DELIVERYKIND = 50 then '16D51F70-5F48-44B6-B584-0AAB3230A762'
							when o.DELIVERYKIND = 51 then '16D51F70-5F48-44B6-B584-0AAB3230A762'
							-- Halva Express 
							when o.DELIVERYKIND = 52 then '56438afa-8a10-11ee-a9b1-00155d0754d9'
							-- Самовывоз
							when o.DELIVERYKIND = 20 then 'c7a6aa0a-9938-4efd-a253-62f648685816'
							else '00000000-0000-0000-0000-000000000000'
						end
				end,			
			d.IsShipped = case when d.IsShipped = 1 then 1 else 0 end,	-- Признак печати не говорит нам об отгрузке этого заказа
			d.IsDeleted = case when (o.STATUS = 3 or (o.STATUS = 6 and o.DELIVERYKIND = 20)) then cast(1 as bit) else cast(0 as bit) end,
			d.ImportanceLevel = 
				case
					-- Если курьеры по МСК, но доставка ТК (не наша курьерская служба)
					when o.DELIVERYKIND in (1, 2, 3, 4, 6, 8, 18, 30, 32, 33, 47) and cod.DeliveryServiceId not in (5)
						then 1	-- Высокий
					when l.DeliveryDateFrom is not null
						then
							case
								--when cast(l.DeliveryDateFrom as date) = cast(@now as date) and (cast(l.DeliveryDateFrom as time) <= '14:00:00.000') 
								when l.DeliveryDateFrom <= @calcDate
									then 2	-- Обычный
								else 3	-- Низкий
							end
						else 3	-- Низкий
				end,
			d.Comments = case 
							when isnull(o.COMMENT,'') = '' then case when e.OrderState = 1 then 'ИзмененияПослеОтгрузки' else '' end
							else case when e.OrderState = 1 then o.COMMENT + ' ИзмененияПослеОтгрузки' else o.COMMENT end
						end,
			d.AuthorId = '86C6A872-1187-4C8B-B382-8DBD917837EC'			
		from 
			#orderIdsForExport e
			join WmsShipmentOrderDocuments d on d.PublicId = e.OrderId
			join CLIENTORDERS o on o.ID = e.OrderId
			left join ClientOrdersDelivery cod on cod.OrderId = o.ID
			left join OrderDeliveryLogistics l on l.ClientOrderID = o.ID and l.Archive = 0
			left join METROLINKS ml on ml.STATIONID = l.StationID
			left join METROLINES line on line.ID = ml.LINEID

		-- Вставляем Документы, которых еще нет в таблице
		insert WmsShipmentOrderDocuments 
		(
			PublicId, ClientId, Number, DocStatus, WmsCreateDate, ShipmentDate, ShipmentDirection, RouteId, 
			IsPartial, IsShipped, IsDeleted, ImportanceLevel, Comments, Operation, AuthorId, CreateDate
		)
		select o.ID, o.CLIENTID, 
			case o.SITEID 
				when '48E0A097-E897-4ABD-8B98-2B3FFC6C405B' then 'rdw-'
                when 'B2803EA7-0BFA-4AA7-B459-F2A997974312' then 'emb-'
                when '9EED7FEB-F8E8-46F5-B515-F66B644B7718' then 'edt-'
				when '5D4463C6-EBA6-4DD5-8618-D07AE3A23D9A' then 'ozon-'
				when 'FABE80CF-AC99-4064-8F2E-CFA701C3E59A' then 'goods-'
				else 'n-'
			end 
			+ 
			case 
				when o.KIND = 3 then cast(o.NUMBER as varchar(13)) 
				else iif(o.PUBLICNUMBER='', cast(o.NUMBER as varchar(13)), o.PUBLICNUMBER)
			end, 
			--cast(1 as int), 
			case o.STATUS  
				when 1 then 1
				when 2 then 1
				when 4 then 1
				when 7 then 9
				when 8 then 9
				when 3 then 11
				when 6 then 11
				when 15 then 8
				else 1
			end,
			o.DATE, 
			isnull(o.ExpectedDate, @now),
			case --o.DELIVERYKIND
					-- курьеры
					when o.DELIVERYKIND in (1, 2, 3, 4, 6, 8, 18, 30, 32, 33, 47) then 
						case
							-- Сервис DalliService
							when cod.DeliveryServiceId = 3 then 2
							-- Сервис Randewoo
							when cod.DeliveryServiceId = 5 then 1
							-- Сервис Доставка Клаб
							when cod.DeliveryServiceId = 9 then 2
							-- Сервис Л-Пост
							when cod.DeliveryServiceId = 11 then 2
							-- Сервис Logsis
							when cod.DeliveryServiceId = 13 then 2
							-- Сервис Интеграл
							when cod.DeliveryServiceId = 14 then 2
							-- Сервис Randewoo
							else -1
						end
					when o.DELIVERYKIND in (7, 19) then 2
					when o.DELIVERYKIND = 5 then 2
					when o.DELIVERYKIND = 12 then 2
					when o.DELIVERYKIND = 13 then 1
					when o.DELIVERYKIND = 14 then 2
					when o.DELIVERYKIND = 48 then 2
					--when 15 then ''
					when o.DELIVERYKIND = 16 then 2
					when o.DELIVERYKIND = 17 then 2
					when o.DELIVERYKIND = 20 then 3
					-- СДЭК
					when o.DELIVERYKIND = 21 then 2
					when o.DELIVERYKIND = 22 then 2
					when o.DELIVERYKIND = 23 then 2
					when o.DELIVERYKIND = 35 then 2
					when o.DELIVERYKIND = 36 then 2
					-- Dostavka-club
					when o.DELIVERYKIND = 39 then 2
					when o.DELIVERYKIND = 40 then 2
					-- Dalli Курьерская ЦФО
					when o.DELIVERYKIND = 49 then 2
					-- Пятерочка
					when o.DELIVERYKIND = 42 then 2
					-- 
					when o.DELIVERYKIND = 43 then 2
					when o.DELIVERYKIND = 44 then 2
					-- Л-Пост
					when o.DELIVERYKIND = 45 then 2
					when o.DELIVERYKIND = 46 then 2
					-- Yandex
					when o.DELIVERYKIND = 24 then 2
					when o.DELIVERYKIND = 25 then 2
					when o.DELIVERYKIND = 26 then 2
					when o.DELIVERYKIND = 27 then 1
					-- Goods
					when o.DELIVERYKIND = 101 then 1
					-- Беру
					when o.DELIVERYKIND = 102 then 1
					-- Boxberry
					when o.DELIVERYKIND = 50 then 2
					when o.DELIVERYKIND = 51 then 2
					-- Halva Express
					when o.DELIVERYKIND = 52 then 2
					-- Бесконтактные
					when o.DELIVERYKIND = 30 then 1
					when o.DELIVERYKIND = 31 then 2
					when o.DELIVERYKIND = 32 then 1
					when o.DELIVERYKIND = 33 then 1
					when o.DELIVERYKIND = 34 then 2
					else -1
				end,
				case 
					when o.CLIENTID in ('498EF36F-4211-4B72-8A40-BAE4175AEEA5','79CD61D2-988A-471E-B73F-71EBC63BB0AB','BA11349E-5EA0-465D-904A-61D6E381E6DC') -- Escentric 
						then '89aa2b93-076e-4325-9cd3-353e59c504dd' 
					when o.CLIENTID = '5B0F388B-5131-4E50-99AB-EF643F0A8D90'	-- Новикова	Новикова Александровна
						then '7a100b3d-6b76-4768-a0a3-175433785f82'
					when o.CLIENTID = '459723EB-F12A-44C6-85B0-BF0B7765AD21'	-- Тимошкова Тимошкова Александровна
						then 'e86affcc-f7c6-453b-b809-a78008f07473'
					else
						case --o.DELIVERYKIND
							-- Курьеры по Москве
							when o.DELIVERYKIND in (1, 2, 3, 4, 6, 8, 18, 30, 32, 33, 47) then
								case
									-- Сервис DalliService
									when cod.DeliveryServiceId = 3 then '38e19270-bb54-4129-978e-a87b7e1193fd'
									-- Сервис Randewoo
									when cod.DeliveryServiceId = 5 then 
										case when line.WmsRouteId is null then '00000000-0000-0000-0000-000000000000' else cast(line.WmsRouteId as varchar(36)) end
									-- Сервис Доставка Клаб
									when cod.DeliveryServiceId = 9 then '7bd02e24-bfbf-4769-aea2-cf089a1d531c'
									-- Сервис Л-Пост
									when cod.DeliveryServiceId = 11 then '218f3820-55da-47a5-a751-81acd14f7b6e'
									-- Сервис Logsis
									when cod.DeliveryServiceId = 13 then '79B6D4EC-43CC-493A-9D2D-AFE51DBCF8D1'
									-- Сервис Интеграл
									when cod.DeliveryServiceId = 14 then '3a1d49d5-9552-43b8-8bd6-537b3d7ea59d'
									-- Не определен
									else '00000000-0000-0000-0000-000000000000'
								end
							-- Нестандартная доставка
							when o.DELIVERYKIND = 13 then '21b86df1-c715-43f1-8353-fc7ead78006f'
							-- Ozon
							when o.DELIVERYKIND = 27 then '21b86df1-c715-43f1-8353-fc7ead78006f'
							-- Goods
							when o.DELIVERYKIND = 101 then '21b86df1-c715-43f1-8353-fc7ead78006f'
							-- Беру
							when o.DELIVERYKIND = 102 then '21b86df1-c715-43f1-8353-fc7ead78006f'
							-- Почта России
							when o.DELIVERYKIND = 5 then '02604e5e-ccb4-4d41-9817-9c2a2fe2a635'					
							when o.DELIVERYKIND = 48 then '02604e5e-ccb4-4d41-9817-9c2a2fe2a635'					
							-- EMS
							when o.DELIVERYKIND = 12 then '1adb74db-47b6-4fa2-857b-d7d8b074b2c5'
							when o.DELIVERYKIND = 14 then '1adb74db-47b6-4fa2-857b-d7d8b074b2c5'
							when o.DELIVERYKIND = 24 then '1adb74db-47b6-4fa2-857b-d7d8b074b2c5'
							-- PickPoint
							when o.DELIVERYKIND = 16 then '1ddc54cc-d2f3-49d4-90cd-4cc613ef7143'
							when o.DELIVERYKIND = 17 then '1ddc54cc-d2f3-49d4-90cd-4cc613ef7143'		
							when o.DELIVERYKIND = 26 then '1ddc54cc-d2f3-49d4-90cd-4cc613ef7143'
							-- СДЭК
							when o.DELIVERYKIND = 21 then '13a90ad4-d180-4938-a5c0-bb9e7af422b8'
							when o.DELIVERYKIND = 22 then '13a90ad4-d180-4938-a5c0-bb9e7af422b8'
							when o.DELIVERYKIND = 23 then '13a90ad4-d180-4938-a5c0-bb9e7af422b8'
							when o.DELIVERYKIND = 35 then '13a90ad4-d180-4938-a5c0-bb9e7af422b8'
							when o.DELIVERYKIND = 36 then '13a90ad4-d180-4938-a5c0-bb9e7af422b8'
							-- Dostavka-club
							when o.DELIVERYKIND = 39 then '7bd02e24-bfbf-4769-aea2-cf089a1d531c'
							when o.DELIVERYKIND = 40 then '7bd02e24-bfbf-4769-aea2-cf089a1d531c'
							-- Dalli Курьерская ЦФО
							when o.DELIVERYKIND = 49 then '7bd02e24-bfbf-4769-aea2-cf089a1d531c'
							-- Пятерочка
							when o.DELIVERYKIND = 42 then '4e178376-15ea-4bc0-bafa-4cd8ac41de0c'
							-- Л-Пост
							when o.DELIVERYKIND = 43 then '218f3820-55da-47a5-a751-81acd14f7b6e'
							when o.DELIVERYKIND = 44 then '218f3820-55da-47a5-a751-81acd14f7b6e'
							-- Yandex
							when o.DELIVERYKIND = 45 then 'ef62b92d-9567-4e42-bc34-a71c61d5c868'
							when o.DELIVERYKIND = 46 then 'ef62b92d-9567-4e42-bc34-a71c61d5c868'
							-- Dalli Service
							when o.DELIVERYKIND = 25 then '38e19270-bb54-4129-978e-a87b7e1193fd'
							-- Курьеры СПб
							when o.DELIVERYKIND in (7, 19, 31, 34) then
								case
									-- Сервис DalliService
									when cod.DeliveryServiceId = 3 then '38e19270-bb54-4129-978e-a87b7e1193fd'
									-- Сервис Доставка Клаб
									when cod.DeliveryServiceId = 9 then '7bd02e24-bfbf-4769-aea2-cf089a1d531c'
									-- Сервис Л-Пост
									when cod.DeliveryServiceId = 11 then '218f3820-55da-47a5-a751-81acd14f7b6e'
									-- Сервис Logsis
									when cod.DeliveryServiceId = 13 then '79B6D4EC-43CC-493A-9D2D-AFE51DBCF8D1'
									-- Сервис Интеграл
									when cod.DeliveryServiceId = 14 then '3a1d49d5-9552-43b8-8bd6-537b3d7ea59d'
									-- Не определен
									else '38e19270-bb54-4129-978e-a87b7e1193fd'
								end
							-- Boxberry
							when o.DELIVERYKIND = 50 then '16D51F70-5F48-44B6-B584-0AAB3230A762'
							when o.DELIVERYKIND = 51 then '16D51F70-5F48-44B6-B584-0AAB3230A762'
							-- Halva Express 
							when o.DELIVERYKIND = 52 then '56438afa-8a10-11ee-a9b1-00155d0754d9'
							-- Самовывоз
							when o.DELIVERYKIND = 20 then 'c7a6aa0a-9938-4efd-a253-62f648685816'
							else '00000000-0000-0000-0000-000000000000'
						end
				end,				
				e.IsPartial, 
				cast(0 as bit),--o.ISPRINTED,	-- Признак печати не говорит нам об отгрузке этого заказа
				case when (o.STATUS = 3 or (o.STATUS = 6 and o.DELIVERYKIND = 20)) then cast(1 as bit) else cast(0 as bit) end,	--cast(0 as bit), 
				-- Приоритет
				case
					-- Если курьеры по МСК, но доставка ТК (не наша курьерская служба)
					when o.DELIVERYKIND in (1, 2, 3, 4, 6, 8, 18, 30, 32, 33, 47) and cod.DeliveryServiceId not in (5)
						then 1	-- Высокий
					when l.DeliveryDateFrom is not null
						then
							case
								--when cast(l.DeliveryDateFrom as date) = cast(@now as date) and (cast(l.DeliveryDateFrom as time) <= '14:00:00.000') 
								when l.DeliveryDateFrom <= @calcDate
									then 2	-- Обычный
								else 3	-- Низкий
							end
						else 3	-- Низкий
				end,
				o.COMMENT,
				1, 
				'86C6A872-1187-4C8B-B382-8DBD917837EC',
				o.DATE
		from 
			#orderIdsForExport e
			join CLIENTORDERS o on o.ID = e.OrderId
			left join ClientOrdersDelivery cod on cod.OrderId = o.ID
			left join OrderDeliveryLogistics l on l.ClientOrderID = o.ID and l.Archive = 0
			left join METROLINKS ml on ml.STATIONID = l.StationID
			left join METROLINES line on line.ID = ml.LINEID
		where not exists (select 1 from WmsShipmentOrderDocuments d where d.PublicId = e.OrderId)
		
		-- Вставляем новые позиции
		insert WmsShipmentOrderDocumentsItems (DocId, ProductId, Sku, Quantity, Price)
		-- Полностью зарезервированные
		select d.Id, i.PRODUCTID, i.SKU, i.Quantity, i.Price
		from #orderIdsForExport o
			join WmsShipmentOrderDocuments d on d.PublicId = o.OrderId and o.IsPartial = 0
			join 
			(	
				select 
					c.CLIENTORDERID, 
					c.PRODUCTID, 
					p.SKU, 
					sum(c.QUANTITY) as 'Quantity', 
					max(iif(isnull(c.FrozenRetailPriceWithDiscount, 0) > 0 and c.IS_GIFT = 0, c.FrozenRetailPriceWithDiscount, c.FROZENRETAILPRICE)) as 'Price'
				from 
					#orderIdsForExport o
					join CLIENTORDERSCONTENT c on c.CLIENTORDERID = o.OrderId and o.IsPartial = 0 and c.RETURNED = 0 and c.QUANTITY > 0
					join PRODUCTS p on p.ID = c.PRODUCTID				
				group by 
					c.CLIENTORDERID, c.PRODUCTID, p.SKU
			) i on i.CLIENTORDERID = o.OrderId
		-- Закомментировал 11.10.2021
		/*union
		-- Частично зарезервированные
		select d.Id, i.PRODUCTID, i.SKU, i.Quantity, i.Price
		from #orderIdsForExport o
			join WmsShipmentOrderDocuments d on d.PublicId = o.OrderId and o.IsPartial = 1
			join 
			(	
				select c.CLIENTORDERID, c.PRODUCTID, p.SKU, sum(c.QUANTITY) as 'Quantity', max(c.FROZENRETAILPRICE) as 'Price'
				from #orderIdsForExport o
					join CLIENTORDERSCONTENT c on c.CLIENTORDERID = o.OrderId and o.IsPartial = 1 and c.RETURNED = 0 and c.QUANTITY > 0
					join PRODUCTS p on p.ID = c.PRODUCTID
				where isnull(c.STOCK_QUANTITY,0) >= c.QUANTITY
				group by c.CLIENTORDERID, c.PRODUCTID, p.SKU
			) i on i.CLIENTORDERID = o.OrderId*/

		-- Дополняем список позиций для частичных заказов, если позиции по какой-то причине остались без резерва
		/*insert WmsShipmentOrderDocumentsItems (DocId, ProductId, Sku, Quantity, Price)
		select i.DocId, i.ProductId, i.Sku, i.Quantity, i.Price
		from @partialItems i			
			left join WmsShipmentOrderDocumentsItems oi on oi.DocId = i.DocId and oi.ProductId = i.ProductId			
		where oi.DocId is null*/

		-- Если есть частично зарезервированные заказы
		/*if exists (select 1 from #orderIdsForExport where IsPartial = 1) begin
			
			-- Добавляем в такие заказы товарную позицию "Товар для блокировки Заказа на отгрузку в WMS" 
			-- (ID = 1A36C1D1-E5BF-4D87-9035-1121E24810B1, SKU = 237984)
			insert WmsShipmentOrderDocumentsItems (DocId, ProductId, Sku, Quantity, Price)
			select d.Id, '1A36C1D1-E5BF-4D87-9035-1121E24810B1', 237984, 1, 99
			from #orderIdsForExport o
				join WmsShipmentOrderDocuments d on d.PublicId = o.OrderId and o.IsPartial = 1

			-- Проверяем, есть ли позиции по частично собранным заказам, которые были ранее отправлены, но сейчас удалены
			/*insert WmsShipmentOrderDocumentsItems (DocId, ProductId, Sku, Quantity, Price)
			select ai.DocId, ai.ProductId, ai.Sku, max(ai.Quantity), max(ai.Price)
			from #orderIdsForExport o
				join WmsShipmentOrderDocuments d on d.PublicId = o.OrderId and o.IsPartial = 1
				join WmsShipmentOrderDocumentsItemsArchive ai on ai.DocId = d.Id				
				left join WmsShipmentOrderDocumentsItems i on ai.DocId = i.DocId and ai.ProductId = i.ProductId
			where i.DocId is null
			group by ai.DocId, ai.ProductId, ai.Sku*/

		end*/
			
		-- 1. -----------------------------------------------------------------------------------------

		-- 2. Добавляем заказы, которых еще нет в таблице ExportOrders --------------------------------

		-- Объявляем таблицу, в которую сохраним уже существующие в таблице ExportOrders идентификаторы заказов клиентов
		declare @existsIds table 
		(
			OrderId			uniqueidentifier	not null,				-- Идентификатор заказа клиента
			Operation		int					not null,				-- Операция
			Primary key (OrderId)
		)
		
		-- "Захватываем" таблицу ExportOrders и запоминаем список заказов клиентов, которые уже есть в таблице
		insert @existsIds (OrderId, Operation)
		select e.OrderId, e.Operation
		from ExportOrders e
			join #orderIdsForExport o on o.OrderId = e.OrderId

		-- Если в таблице уже есть чать заказов клиентов
		if exists(select 1 from @existsIds) begin
							
			-- Архивируем существующие заказы клиентов (идентификатор сессии равен нулю: SessionId = 0)
			insert ExportOrdersSessionItemsArchive (SessionId, Id, OrderId, Operation, ReportDate)
			select 0, i.Id, i.OrderId, i.Operation, i.ReportDate
			from ExportOrders i
				join @existsIds e on e.OrderId = i.OrderId
			
			-- Удаляем существующие заказы клиентов
			delete i 			
			from ExportOrders i
				join @existsIds e on e.OrderId = i.OrderId

		end 
		
		-- Вставляем новые записи в таблицу ExportOrders
		insert ExportOrders (OrderId, Operation, IsPartial, OrderState)
		select OrderId, 2, IsPartial, OrderState
		from #orderIdsForExport
		
		-- 2. -----------------------------------------------------------------------------------------

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
