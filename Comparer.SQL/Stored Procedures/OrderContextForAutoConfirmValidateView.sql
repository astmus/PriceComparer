create proc OrderContextForAutoConfirmValidateView
(
	@OrderId		uniqueidentifier	-- Идентификатор заказа
) as
begin

	declare 
		@checkDate date = GetDate()

	declare 
		@clientId		uniqueidentifier,
		@date			datetime,
		@hasDoubles		int = 0
			   
	select 
		@clientId	= o.CLIENTID,
		@date		= o.DATE
	 from CLIENTORDERS o
	 where o.ID = @OrderId

	-- Заказ
	select 
		o.ID						as 'Id',
		o.PUBLICNUMBER				as 'PublicNumber',
		o.NUMBER					as 'Number',
		o.DATE						as 'CreatedDate',
		cast(o.DELIVERYKIND as int)	as 'DeliveryId',
		cast(o.PAYMENTKIND as int)	as 'PaymentId',
		o.DELIVERY_INFO				as 'DeliveryInfo',
		o.FROZENSUM					as 'Sum',
		o.PAIDSUM					as 'PaidSum',
		o.MOBILE					as 'Mobile',
		lower(o.Email)				as 'Email',
		o.SITEID					as 'SiteId',
		cast(o.STATUS as int)		as 'StatusId',
		cast(o.KIND as int)			as 'KindId',
		isnull(o.COMMENT, '')		as 'Comment'
	from CLIENTORDERS o 
	where o.ID = @OrderId
			
	-- Определяем, есть ли потенциальные дубли	
	/*
	select @hasDoubles = count(1) 
	from CLIENTORDERS o 
	where o.CLIENTID = @clientId 
		and o.ID <> @OrderId
		and o.Date > dateadd(mm, -10, @date)
		and o.Date < dateadd(mm, 10, @date)
	*/

	-- Клиент
	select
		c.ID										as 'Id',
		c.NAME										as 'Name',
		c.LASTNAME									as 'LastName',
		c.FATHERNAME								as 'FatherName',
		cast(c.Sex as int)							as 'Sex',
		c.MOBILEPHONE								as 'Mobile',
		lower(c.EMAIL)								as 'Email',
		c.IsEmployee								as 'IsEmployee',
		isnull(ords.Total,0)						as 'OrdersCount',
		isnull(retOrds.Total,0)						as 'ReturnsCount',
		isnull(createOrds.Total,0)					as 'CreatedCount',
		isnull(withReceivedOrds.TotalReceived, 0)	as 'ReceivedCount',
		iif(bl.ClientId is null, cast(0 as bit), cast(1 as bit))	
													as 'InBlackList',
		iif(c.Id in 
			(
			'498EF36F-4211-4B72-8A40-BAE4175AEEA5',
			'79CD61D2-988A-471E-B73F-71EBC63BB0AB',
			'BA11349E-5EA0-465D-904A-61D6E381E6DC',
			'5B0F388B-5131-4E50-99AB-EF643F0A8D90',	-- Новикова	Новикова Александровна
			'459723EB-F12A-44C6-85B0-BF0B7765AD21'	-- Тимошкова Тимошкова Александровна
			),
		cast(1 as bit) ,cast(0 as bit))				as 'Excentric',
		c.ClientType								as 'ClientType',		
		isnull(allOrds.Total, 0)					as 'TotalOrdersCount'
		--@hasDoubles					as 'HasDoubles'
	from CLIENTS c		
		left join (
			select o.CLIENTID as 'ClientId', 1 as 'Total' 
			from
			(
				select 
					o1.CLIENTID, o1.STATUS, row_number() over (order by o1.DATE desc) as 'RowNo'
				from CLIENTORDERS o1
				where o1.CLIENTID = @clientId and o1.ID <> @OrderId and o1.DATE < @date -- Смотрим предыдущий к текущему заказ
			) o
			where o.RowNo = 1 and o.STATUS in (3,5,6,16) 
			--from CLIENTORDERS o
			--where o.CLIENTID = @clientId and o.STATUS in (3,5,6) and o.Date < @date
			--group by o.CLIENTID
		) ords on ords.ClientId = c.ID
		left join (
			select o.CLIENTID as 'ClientId', count(1) as 'Total'
			from CLIENTORDERS o
			where o.CLIENTID = @clientId and o.STATUS = 6
			group by o.CLIENTID
		) retOrds on retOrds.ClientId = c.ID
		left join (
			select o.CLIENTID as 'ClientId', count(1) as 'Total'
			from CLIENTORDERS o
			where o.CLIENTID = @clientId --and o.STATUS = 1
				and o.ID <> @OrderId
				and o.Date > dateadd(MI, -10, @date)
				and o.Date < dateadd(MI, 10, @date)
			group by o.CLIENTID
		) createOrds on createOrds.ClientId = c.ID
		left join (
			select co.CLIENTID as 'ClientId', count(1) as 'TotalReceived' 
			from CLIENTORDERS co
			where co.CLIENTID = @clientId and co.STATUS in (5, 4) -- имеются полученные / оплаченные заказы 
			group by co.CLIENTID
		) withReceivedOrds on withReceivedOrds.ClientId = c.ID
		left join ClientsBlackList bl on c.ID = bl.ClientId
		left join (
			select co.CLIENTID as 'ClientId', count(1) as 'Total' 
			from CLIENTORDERS co
			where co.CLIENTID = @clientId  
			group by co.CLIENTID
		) allOrds on allOrds.ClientId = c.ID

	where c.ID = @clientId

	-- Адрес
	select
		a.AOGUID					as 'FiasGuid',		
		a.FIASSTATUS				as 'FiasStatus',
		a.COUNTRYID					as 'CountryId',
		a.REGION					as 'Region',
		a.DISTRICT					as 'District',
		a.CITY						as 'City',
		a.LOCALITY					as 'Locality',
		a.AUTONOMAREA				as 'Autonomarea',
		a.STREET					as 'Street',
		a.HOUSE_TYPE				as 'House_Type',
		a.HOUSE						as 'House',
		a.BLOCK_TYPE				as 'Block_Type',
		a.BLOCK						as 'Block',
		a.BLOCK2_TYPE				as 'Block2_Type',
		a.BLOCK2					as 'Block2',
		a.FLAT_TYPE					as 'Flat_Type',
		a.FLAT						as 'Flat',
		a.ZIPCODE					as 'Zip',
		a.FIRSTNAME					as 'ContactName',
		a.LASTNAME					as 'ContactLastName',
		a.MIDDLENAME				as 'ContactFatherName',
		a.CONTACTPHONE				as 'ContactMobile',
		a.COMMENTS					as 'Comments',
		isnull(a.IsFIASValid,0)		as 'IsFIASValid'
	from CLIENTORDERADDRESSES a
	where a.CLIENTORDERID = @OrderId

	-- Логистика
	select 
		l.DeliveryDateFrom			as 'DateFrom',
		l.DeliveryDateTo			as 'DateTo',
		l.StationID					as 'MetroId'
	from OrderDeliveryLogistics l
	where l.ClientOrderID = @OrderId and l.Archive = 0

	-- Товары
	select 
		c.ID						as 'Id',
		c.PRODUCTID					as 'ProductId',
		c.QUANTITY					as 'Quantity',
		c.IS_Gift					as 'IsGift',
		p.SKU						as 'Sku',
		p.PRICE						as 'Price',
		isnull(ps.FreeStock, 0)		as 'Stock',
		case when f.PRODUCTID is null then cast(0 as bit) else cast(1 as bit) end 
									as 'IsProbnik',
		case when v.PRODUCTID is null then cast(0 as bit) else cast(1 as bit) end 
									as 'IsVintage',
		case when p.NAME = 'Электронный сертификат' then cast(1 as bit) else cast(0 as bit) end 
									as 'IsСertificate',
		case when CHARINDEX('уценка', LOWER(p.CHILDNAME))>0 then cast(1 as bit) else cast(0 as bit) end 
									as 'IsMarkdown',
		case when p.MANID in ('5E0CCCCB-D638-462F-A414-776CF5B2137C', 'DD6B6618-7C30-494F-963C-140C642999FE') 
			then cast(1 as bit) else cast(0 as bit) 
		end 						as 'IsAromaBox',
		case when r.CATALOGPRODUCTID is not null
			then cast(1 as bit) else cast(0 as bit) 
		end 						as 'IsOtlivant',
		cast(1 as bit)				as 'IsParfume',
		c.FROZENRETAILPRICE			as 'FrozenPrice'
	from 
		CLIENTORDERSCONTENT c
		join PRODUCTS p on p.ID = c.PRODUCTID
		left join PRODUCTSFEATURES f on f.PRODUCTID = p.ID and f.FEATUREID = 13		
		left join 
		(
			select 
				distinct c.PRODUCTID 
			from 
				CATEGORIESPRODUCTSLINKS c 
			where 
				c.CATEGORYID in ('3B457FEB-3C79-4B7B-AE1C-4C2AAF8532FC','192739C3-98ED-4E56-87A3-EC16FA6D69D0')
		) v on v.PRODUCTID = p.ID
		left join
		(
			select
				 distinct l.CATALOGPRODUCTID
			from Links l
				join PricesRecords rec on rec.RecordIndex = l.PriceRecordIndex and rec.Deleted = 0 and rec.Used = 1
				join Prices pr on pr.ID = rec.PriceId and pr.IsActive = 1
			where
				pr.DISID = '1ECE5050-003B-474E-8AF9-36DCC9A1112B'
		) r on r.CATALOGPRODUCTID = p.ID
		left join ShowcaseProductsStock ps on ps.ProductId = p.ID and ps.SiteId = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'
	where 
		c.CLIENTORDERID = @OrderId
	
	-- Связи с поставщиками
	select
		l.CATALOGPRODUCTID			as 'ProductId',
		d.ID						as 'DistributorId',
		d.NAME						as 'DistributorName',
		d.GOINPURCHASELIST			as 'UseInPurchase',
		pr.ID						as 'PriceId',
		pr.NAME						as 'PriceName',
		--(select top 1 1 from DistributorFreeDays where DISTRIBUTORID = d.ID AND freeday = @checkDate) 
		iif(f1.FREEDAY is null, cast(0 as bit), cast(1 as bit))
									as 'IsOffToday',
		--(select top 1 1 from DistributorFreeDays where DISTRIBUTORID = d.ID AND freeday = DateAdd(day, 1, @checkDate)) 
		iif(f2.FREEDAY is null, cast(0 as bit), cast(1 as bit))
									as 'IsOffTomorrow',
		d.IsGulden					as 'IsGulden'
	from
		CLIENTORDERSCONTENT c
		join LINKS l WITH (NOLOCK) on l.CATALOGPRODUCTID = c.PRODUCTID and c.CLIENTORDERID = @OrderId
		join PRICESRECORDS rec WITH (NOLOCK) on rec.RECORDINDEX = l.PRICERECORDINDEX and rec.DELETED = 0 and rec.USED = 1
		join PRICES pr WITH (NOLOCK) on pr.ID = rec.PRICEID and pr.ISACTIVE = 1
		join DISTRIBUTORS d WITH (NOLOCK) on d.ID = pr.DISID and d.ACTIVE = 1
		left join DistributorFreeDays f1 on f1.DISTRIBUTORID = d.ID AND f1.FREEDAY = @checkDate
		left join DistributorFreeDays f2 on f2.DISTRIBUTORID = d.ID AND f2.FREEDAY = DateAdd(day, 1, @checkDate)

	-- История заказов клиента (последние 3 заказа)
	select 
		-- Заказ
		o.ID						as 'OrderId',
		o.[DATE]					as 'CreatedDate',
		cast(o.[Status] as int)		as 'StatusId',
		cast(o.DELIVERYKIND as int)	as 'DeliveryKindId',
		o.FROZENSUM					as 'Sum',
		o.PAIDSUM					as 'PaidSum',
		-- Адрес
		isnull(a.AOGUID, '00000000-0000-0000-0000-000000000000')
									as 'FiasGuid',			
		a.COUNTRYID					as 'CountryId',
		a.REGION					as 'Region',
		a.DISTRICT					as 'District',
		a.CITY						as 'City',
		a.LOCALITY					as 'Locality',
		a.AUTONOMAREA				as 'Autonomarea',
		a.STREET					as 'Street',
		a.ZIPCODE					as 'Zip',
		-- Логистика
		isnull(l.DeliveryDateFrom,lo.DELIVERYDATEFROM)
									as 'DeliveryDateFrom',
		isnull(l.DeliveryDateTo, lo.DELIVERYDATETO)
									as 'DeliveryDateTo',
		isnull(l.StationID, lo.STATIONID)
									as 'DeliveryMetroStationId'
	from 
		CLIENTORDERS o
		join CLIENTORDERADDRESSES a on a.CLIENTORDERID = o.ID
		left join OrderDeliveryLogistics l on l.ClientOrderID = o.ID and l.Archive = 0
		left join LogisticsOrders lo on lo.CLIENTORDERID = o.ID
	where 
		o.CLIENTID = @clientId
		and o.ID <> @OrderId
		and o.DATE > dateadd(year, -1, getdate())
	order by	
		o.DATE desc

end
