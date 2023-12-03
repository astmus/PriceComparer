create procedure OrdersByReservedProductMonitorView 
(
	@ProductId		uniqueidentifier		-- Идентификатор товара
) as
begin

	select 
		o.ID							as 'Id', 
		o.NUMBER						as 'Number', 
		case when o.PUBLICNUMBER = '' then cast(o.NUMBER as varchar(10)) else o.PUBLICNUMBER end 
										as 'PublicNumber', 
		o.DATE							as 'CreatedDate', 
		o.ExpectedDate					as 'ExpectedDate',
		st.Name							as 'StatusName', 
		isnull(d.NAME,'Не определен')	as 'DeliveryKindName', 
		c.QUANTITY						as 'Quantity', 
		sum(c.STOCK_QUANTITY)			as 'ReservedCount'
	from 
		CLIENTORDERS o with (nolock)
		join CLIENTORDERSCONTENT c with(nolock) on o.ID = c.CLIENTORDERID and c.PRODUCTID = @ProductId and c.RETURNED = 0 and c.STOCK_QUANTITY > 0
		join CLIENTORDERSTATUSES st on st.ID = o.STATUS
		left join DELIVERYTYPES d on d.ID = o.DELIVERYKIND
		left join WmsShipmentDocuments w on w.PublicId = o.ID and w.DocStatus = 10
	where 
		o.PACKED = 0
		and o.STATUS in (2,4,7,8)
		and w.PublicId is null
	group by 
		o.ID, o.NUMBER, o.PUBLICNUMBER, o.DATE, o.ExpectedDate, st.NAME, d.NAME, c.QUANTITY
	union
	select 
		o.ID								as 'Id', 
		o.NUMBER							as 'Number', 
		case when o.PUBLICNUMBER = '' then cast(o.NUMBER as varchar(10)) else o.PUBLICNUMBER end 
											as 'PublicNumber',
		o.DATE								as 'CreatedDate', 
		o.ExpectedDate						as 'ExpectedDate',
		st.Name								as 'StatusName', 
		isnull(d.NAME,'Не определен')		as 'DeliveryKindName', 
		c.QUANTITY							as 'Quantity', 
		sum(c.STOCK_QUANTITY)				as 'ReservedCount'
	from 
		CLIENTORDERS o with (nolock)
		join CLIENTORDERSCONTENT c with(nolock) on o.ID = c.CLIENTORDERID and c.PRODUCTID = @ProductId and c.RETURNED = 0
		join CLIENTORDERSTATUSES st on st.ID = o.STATUS
		left join DELIVERYTYPES d on d.ID = o.DELIVERYKIND
		left join WmsShipmentDocuments w on w.PublicId = o.ID and w.DocStatus = 10
		left join _excludedOrdersForReserves e on e.OrderId = o.ID
	where 
		w.PublicId is null
		-- Исключенные заказы
		and e.OrderId is null
		and
		(
			-- Статус заказа "Готов к отгрузке" или "Готов к выдаче"					
			(
				o.STATUS in (14, 15)
			)
			-- Статус заказа "Отправлен" (ТК)
			-- и есть признак "Упакован"
			or
			(
				o.STATUS in (9, 16, 17)
				and
				o.PACKED = 1
				and 
				o.DATE > '01/01/2023'
			)
			-- Статус заказа "Получен клиентом" (Самовывоз)
			-- и есть признак "Упакован"
			or
			(
				o.STATUS = 5
				and
				o.PACKED = 1
				and 
				o.DATE > '01/01/2023'
				and
				o.SITEID <> '14F7D905-31CB-469A-91AC-0E04BC8F7AF3'	-- Не розлив
			)
		)
	group by 
		o.ID, o.NUMBER, o.PUBLICNUMBER, o.DATE, o.ExpectedDate, st.NAME, d.NAME, c.QUANTITY
	union
	select 
		w.PublicId							as 'Id', 
		cast(-1 as int)						as 'Number', 
		w.Number							as 'PublicNumber',
		w.CreateDate						as 'CreatedDate', 
		w.ShipmentDate						as 'ExpectedDate',
		case w.DocStatus
			when 1 then 'Создан'
			when 8 then 'Готов к отгрузке'
			when 9 then 'Заблокирован'
			when 10 then 'Отгружен'
			when 11 then 'Отменен'
			else '?'
		end									as 'StatusName', 
		case w.ShipmentDirection
			when 1 then 'Курьерская доставка'
			when 2 then 'Доставка транспортной компанией'
			when 3 then 'Самовывоз'
			when 4 then 'Отгрузка на розлив'
			else '?'
		end									as 'DeliveryKindName', 
		i.Quantity							as 'Quantity', 
		sum(i.Quantity)						as 'ReservedCount'
	from 
		WmsShipmentDocuments w with(nolock)
		join WmsShipmentDocumentsItems i with(nolock) on w.Id = i.DocId and i.ProductId = @ProductId
	where 
		w.OuterOrder = 1 
		and w.DocStatus < 10
	group by 
		w.PublicId, w.Number, w.CreateDate, w.DocStatus, w.ShipmentDate, ShipmentDirection, i.Quantity
	order by 
		o.DATE desc

end
