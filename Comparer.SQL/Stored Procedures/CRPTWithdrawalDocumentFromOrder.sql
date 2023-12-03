create proc CRPTWithdrawalDocumentFromOrder
(
	@OrderId		uniqueidentifier	-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ Р·Р°РєР°Р·Р°
)
as
begin

	-- Р—Р°РєР°Р·
	select 
	'RETAIL'			as 'Action',					
	 getdate()			as 'ActionDate',				
	 co.Date			as 'PrimaryDocumentDate', 	
	 co.PublicNumber	as 'PrimaryDocumentNumber',	
	'OTHER'				as  'PrimaryDocumentType',		
	'7715489209'		as  'Inn',						
	 null				as  'Kkt_number',				
	 co.PublicNumber	as	'PrimaryDocumentName'		
	from  ClientOrders co
	where	co.Id = @OrderId


	-- РўРѕРІР°СЂС‹
	select
		oc.PRODUCTID			AS 'ProductId',
		om.DataMatrix			as 'DataMatrix', 
		p.SKU					AS 'Sku',
		oc.FROZENRETAILPRICE	AS 'Price',
		oc.quantity				AS 'Quantity',
		m.NAME					AS 'BrandName',
		rtrim(p.NAME + ' ' + p.CHILDNAME)
								AS 'Name',
		null					as 'PrimaryDocumentDate',
		null					as 'PrimaryDocumentNumber',
		null					as 'PrimaryDocumentName',
		oc.FROZENRETAILPRICE*100 as 'ProductCost'

	from
		CLIENTORDERSCONTENT oc
		join PRODUCTS p			on oc.PRODUCTID = p.ID
		join MANUFACTURERS m	on m.ID = p.MANID
		left join 	OrderContentDataMatrixes om on 	OrderId = @OrderId and om.ProductId=p.Id
	where
		oc.CLIENTORDERID = @OrderId
		and oc.IS_GIFT = 0
		and oc.FROZENRETAILPRICE > 0
		and om.DataMatrix is not null
	
end
