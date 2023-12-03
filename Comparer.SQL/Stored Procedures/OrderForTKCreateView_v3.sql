create proc dbo.OrderForTKCreateView_v3
(
	@OrderId		uniqueidentifier		-- Идентификатор заказа
) as
begin

	-- Информация о заказе
	select
		o.ID							as 'Id',
		o.NUMBER						as 'Number',
		iif(o.PUBLICNUMBER = '', cast(o.NUMBER as varchar(10)), o.PUBLICNUMBER) 
										as 'PublicNumber',
		o.SITEID						as 'SiteId',
		ISNULL(s.NAME, '')				as 'SiteName',
		ISNULL(s.NAME, '')				as 'SiteShortName',
		cast(o.DELIVERYKIND as int)		as 'DeliveryKindId',
		case when o.DELIVERYKIND IN (16,17,21,22,26) then o.DELIVERY_INFO else '' end 
										as 'DeliveryInfo',
		iif(cod.DeliveryServiceId is null, isnull(dk.ServiceId, 0), cod.DeliveryServiceId)
										as 'ServiceId',
		cast(o.PAYMENTKIND as int)		as 'PaymentKindId',
		o.STATUS						as 'StatusId',
		iif(c.IsEmployee = 1, o.Frozensum,  o.PAIDSUM) 
										as 'PaidSum',
		o.FROZENSUM						as 'Sum',
		o.DELIVERY						as 'DeliveryCost',
		o.FEE							as 'Fee',
		o.EMAIL							as 'Email',
		o.MOBILE						as 'Phone',
		o.COMMENT						as 'Comment',
		o.WEIGHT						as 'Weight'
	from CLIENTORDERS o
		join CLIENTS c on o.CLIENTID = c.ID
		left join ApiDeliveryServicesCastOrderDeliveryKinds dk on dk.DeliveryKindId = o.DELIVERYKIND
		left join SITES s on s.ID = o.SITEID
		left join ClientOrdersDelivery cod on o.id = cod.OrderId
	where o.Id = @OrderId;

	-- Информация о клиенте
	select	c.ID as 'Id',
			c.NAME as 'Name',
			c.LASTNAME as 'LastName',
			c.FATHERNAME as 'FatherName',
			c.MOBILEPHONE as 'Phone',
			c.EMAIL as 'Email',
			c.IsEmployee as 'IsEmployee'
	from CLIENTORDERS o
		join CLIENTS c on c.ID = o.CLIENTID and o.ID = @OrderId

	-- Информация об адресе
	select	a.ID as 'Id',
			a.ZIPCODE as 'Zip',
			isnull(c.NAME,'') as 'Country',
			a.REGION as 'Region',
			a.DISTRICT as 'District',
			a.LOCALITY as 'Locality',
			a.URBANAREA as 'Area',
			a.CITY as 'City', 
			a.STREET as 'Street', 
			case when a.HOUSE = '' then '' else a.HOUSE_TYPE + ' ' + a.HOUSE end as 'House',
			case when a.BLOCK = '' then '' else a.BLOCK_TYPE + ' ' + a.BLOCK end as 'Block',
			case when a.FLAT = '' then '' else a.FLAT_TYPE + ' ' + a.FLAT end as 'Flat',
			a.FIRSTNAME as 'ContactName',
			a.LASTNAME as 'ContactSurname',
			a.MIDDLENAME as 'ContactLastName',
			a.CONTACTPHONE as 'ContactPhone'
	from CLIENTORDERADDRESSES a
		left join COUNTRIES c on c.ID = a.COUNTRYID
	where a.ClientOrderId = @OrderId
	
	-- Информация о товарах
	select	c.CLIENTORDERID as 'OrderId',
			p.Id as 'Id',
			p.SKU as 'Sku', 
			rtrim(p.NAME + ' ' + p.CHILDNAME) as 'Name',
			m.NAME as 'Brand',
			c.QUANTITY as 'Quantity',
			c.FROZENRETAILPRICE as 'Price',
			c.IS_GIFT as 'IsGift'
	from CLIENTORDERSCONTENT c
		join PRODUCTS p on p.ID = c.PRODUCTID and c.RETURNED = 0
		join MANUFACTURERS m on m.ID = p.MANID
	where c.CLIENTORDERID = @OrderId
	order by c.IS_GIFT desc, p.NAME

	-- Информация о сроках доставки
	select  l.OrderId					as 'OrderId',
			l.DeliveryFrom				as 'DateDeliveryFrom',
			l.DeliveryTo				as 'DateDeliveryTo', 
			isnull(l.MetroStation,'')	as 'MetroStation', 
			isnull(l.MetroLine,'')		as 'MetroLine', 
			isnull(l.MetroLineColor,'')	as 'MetroLineColor'
		from ( 
			select row_number() over (partition by dl.ClientOrderID order by dl.Archive, dl.ID desc) as RecNo,
				dl.ClientOrderID			as 'OrderId',
				dl.DeliveryDateFrom			as 'DeliveryFrom', 
				dl.DeliveryDateTo			as 'DeliveryTo', 
				st.NAME						as 'MetroStation', 
				l.NAME						as 'MetroLine', 
				l.ColorName					as 'MetroLineColor'
			from OrderDeliveryLogistics dl 
				left join METROSTATIONS st on st.ID = dl.StationID
				left join METROLINKS ml on ml.STATIONID = st.ID
				left join METROLINES l on l.ID = ml.LINEID
			where dl.ClientOrderID = @OrderId 
		) l
		where l.RecNo = 1

	-- Информация о ТК
	select	cast(do.InnerId as nvarchar(36))				as 'InnerId',
			do.OuterId										as 'OuterId',
			do.ServiceId									as 'ServiceId',
			do.AccountId									as 'AccountId',
			do.CreatedDate									as 'RegistrationDate',
			isnull(o.DISPATCHNUMBER,'')						as 'TrackNumber',
			-- Доп инфо
			isnull(i.IKNId,0)								as 'IknId',
			cast(isnull(i.LabelDowloadCount,0) as int)		as 'LabelDownloadCount'
	from ApiDeliveryServiceOrders do
		join CLIENTORDERS o on o.ID = do.InnerId
		left join ApiDeliveryServiceOrdersInfo i on i.InnerId = do.InnerId
	where do.InnerId = @OrderId

end
