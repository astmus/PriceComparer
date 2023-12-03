create proc OrderContentPurchasePriceSet
(
	@ErrorMes		nvarchar(4000)	out		-- Сообщение об ошибке
)
as
begin

	begin try

		-- Временная таблица для товарных позиций заказов
		create table #orderItems
		(
			OrderId				uniqueidentifier	not null,
			ProductId			uniqueidentifier	not null,
			Number				int					not null,
			Sku					int					not null,

			IsOtlivant			bit					not null default (0),
			IsAromaBox			bit					not null default (0),
			
			WarehousePrice		float					null,
			WarehouseCurrencyId	int						null

			-- primary key (OrderId, ProductId)
		)

		insert into #orderItems
			(OrderId, Number, ProductId, Sku, IsOtlivant, IsAromaBox)
		select
			o.ID, o.NUMBER, p.ID, p.SKU, p.IsOtlivant, iif(p.ComponentTypeId = 1, 1, 0)
		from 
			CLIENTORDERS o				
			JOIN CLIENTORDERSCONTENT oc		ON oc.CLIENTORDERID = o.ID
			JOIN PRODUCTS p					ON p.ID = oc.PRODUCTID
		where 
			o.[date] > '1/09/2023'			
			AND o.[Status] in (2, 14, 15, 17)
			AND o.[SITEID] = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'
			AND oc.Warehouseprice is Null
			AND oc.IS_GIFT = 0
			--AND o.ID = '723C9786-6264-4BEB-A1B6-56D1123DE14D'	-- !DEV


		-- Обновляем цену во временной таблице >>>

		-- Розлив
		update t 
		set
			t.WarehousePrice		= r.Price,
			t.WarehouseCurrencyId	= r.DEFAULTCURRENCY
		from 
			#orderItems t
			JOIN 
			(
				select 
					l.CATALOGPRODUCTID, rec.PRICE, pr.DEFAULTCURRENCY,
					row_number() over (partition by l.CATALOGPRODUCTID order by pr.DEFAULTCURRENCY) as RecNo
				from 
					LINKS l with (nolock)
					join PRICESRECORDS rec with (nolock) on rec.RECORDINDEX = l.PRICERECORDINDEX and rec.DELETED = 0 and rec.USED = 1
					join PRICES pr with (nolock)		 on pr.ID = rec.PRICEID
				where
					pr.DISID = '1ECE5050-003B-474E-8AF9-36DCC9A1112B'
			) r on r.CATALOGPRODUCTID = t.ProductId and r.RecNo = 1


		-- Документы закупки
		update t 
		set
			t.WarehousePrice		= ptc.FactPrice,
			t.WarehouseCurrencyId	= ptc.Currency
		from 
			#orderItems t
			JOIN 
			(
				select
					*, row_number() over (partition by t.Number, t.Sku order by t.ReportDate desc) as 'RowNo'
				from
				(
					select h.Code, h.Number, h.Sku, h.ReportDate from PurchaseTasksContentDistributionHistory h where h.FactQuantity > 0
					UNION
					select h.Code, h.Number, h.Sku, h.ReportDate from PurchaseTasksContentDistributionHistoryArchive h where h.FactQuantity > 0
				) t 
			) h ON t.Number = h.Number AND t.Sku = h.Sku AND h.RowNo = 1
			JOIN PurchasesTasksContent ptc	ON h.Code = ptc.Code AND t.sku = ptc.SKU AND ptc.ARCHIVE = 0


		-- Документы из УТ
		update t 
		set
			t.WarehousePrice		= ut.Price,
			t.WarehouseCurrencyId	= ut.CurrencyId
		from 
			#orderItems t
			JOIN 
			(
				select 
					pr.ProductId, pr.Price, pr.CurrencyId,
					row_number() over (partition by pr.ProductId order by d.[Date] desc) as 'RowNo'
				from
					UtPriceDocuments d
					join UtPrices pr on d.Id = pr.DocId
					join Products p on p.ID = pr.ProductId
				where
					d.IsCancelled = 0
					and pr.PriceTypeId in (1, 2)	-- Базовая (RUB) / 'Базовая (USD)
			) ut on ut.ProductId = t.ProductId and RowNo = 1
		where
			t.WarehousePrice is Null
			AND t.IsOtlivant = 0
			AND t.IsAromaBox = 0


		-- Обновляем себестоимость в заказах
		update c
		set
			c.WarehousePrice		= i.WarehousePrice,
			c.WarehouseCurrency		= i.WarehouseCurrencyId
		from	
			#orderItems i
			join CLIENTORDERSCONTENT c on i.OrderId = c.CLIENTORDERID and i.ProductId = c.PRODUCTID
		where
			i.WarehousePrice is not null


		return 0

	end try 
	begin catch 		
		set @ErrorMes = error_message()
		return 1
	end catch

end
