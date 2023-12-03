create proc OrderForTKCreateView_v5
(
	@OrderId		uniqueidentifier		-- Идентификатор заказа
) as
begin

	-- Информация о заказе
	select
		o.ID							as 'Id',
		o.NUMBER						as 'Number',
		case
			when r.NewOrderId is null
				then iif(o.PUBLICNUMBER = '', cast(o.NUMBER as varchar(10)), o.PUBLICNUMBER) 
			else
				iif(o.PUBLICNUMBER = '', cast(o.NUMBER as varchar(10)), o.PUBLICNUMBER) + '-2'
		end
										as 'PublicNumber',
		o.PublicId						as 'PublicId',
		o.SITEID						as 'SiteId',
		ISNULL(s.NAME, '')				as 'SiteName',
		ISNULL(s.NAME, '')				as 'SiteShortName',
		cast(o.DELIVERYKIND as int)		as 'DeliveryKindId',
		--case when o.DELIVERYKIND IN (7, 16, 17, 21,22, 26, 35, 39, 40, 42, 43, 44, 45, 46) then o.DELIVERY_INFO else '' end 
		o.DELIVERY_INFO					as 'DeliveryInfo',
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
		o.WEIGHT						as 'Weight',
		pd.DepartmentId					as 'DepartmentId'
	from
		CLIENTORDERS o
		join CLIENTS c on o.CLIENTID = c.ID
		left join ApiDeliveryServicesCastOrderDeliveryKinds dk on dk.DeliveryKindId = o.DELIVERYKIND
		left join SITES s on s.ID = o.SITEID
		left join ClientOrdersDelivery cod on o.id = cod.OrderId
		left join ClientOrdersPaymentData pd on pd.OrderId = o.ID
		left join OrdersForRecreate r on r.NewOrderId = o.ID
	where 
		o.Id = @OrderId;

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
			c.CodeISO as 'CountryCodeISO',
			isnull(c.NAME,'') as 'Country',
			isnull(c.Alfa2,'') as 'CountryCode',			
			a.REGION as 'Region',
			a.DISTRICT as 'District',
			a.LOCALITY as 'Locality',
			a.URBANAREA as 'Area',
			a.CITY as 'City', 
			a.STREET as 'Street', 
			case when a.HOUSE = '' then '' else a.HOUSE_TYPE + ' ' + a.HOUSE end as 'House',
			case when a.BLOCK = '' then '' else a.BLOCK_TYPE + ' ' + a.BLOCK end as 'Block',
			case when a.BLOCK2 = '' then '' else a.BLOCK2_TYPE + ' ' + a.BLOCK2 end as 'Block2',
			case when a.FLAT = '' then '' else a.FLAT_TYPE + ' ' + a.FLAT end as 'Flat',
			a.FIRSTNAME as 'ContactName',
			a.LASTNAME as 'ContactSurname',
			a.MIDDLENAME as 'ContactLastName',
			a.CONTACTPHONE as 'ContactPhone',
			a.COMMENTS as 'Comments'
	from
		CLIENTORDERADDRESSES a
		left join COUNTRIES c on c.ID = a.COUNTRYID
	where
		a.ClientOrderId = @OrderId
	
	-- Информация о товарах
	select	c.CLIENTORDERID						as 'OrderId',
			p.Id								as 'Id',
			p.SKU								as 'Sku', 
			rtrim(p.NAME + ' ' + p.CHILDNAME)	as 'Name',
			m.NAME								as 'Brand',
			c.QUANTITY							as 'Quantity',
			c.FROZENRETAILPRICE					as 'Price',
			c.IS_GIFT							as 'IsGift',
			p.[Weight]							as 'Weight',
			c.FrozenRetailPriceWithDiscount		as 'FrozenRetailPriceWithDiscount'
	from CLIENTORDERSCONTENT c
		join PRODUCTS p on p.ID = c.PRODUCTID and c.RETURNED = 0
		join MANUFACTURERS m on m.ID = p.MANID
	where c.CLIENTORDERID = @OrderId
	order by c.IS_GIFT desc, p.NAME

	-- Маркировки
	select distinct
		c.PRODUCTID							as 'ProductId',
		dm.DataMatrix						as 'DataMatrix',
		isnull(dm.FullDataMatrix, '')		as 'FullDataMatrix'
	from CLIENTORDERSCONTENT c
		join OrderContentDataMatrixes dm on dm.ProductId = c.PRODUCTID and dm.OrderId = @OrderId
		left join SUZOrderItemDataMatrixes s on SUBSTRING(s.DataMatrix, 0, 32) = dm.DataMatrix
	where 
		s.Id is null

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
