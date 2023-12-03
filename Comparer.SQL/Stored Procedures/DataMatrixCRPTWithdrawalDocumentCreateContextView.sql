create proc DataMatrixCRPTWithdrawalDocumentCreateContextView
(
	@OrderId			uniqueidentifier,	-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ Р·Р°РєР°Р·Р°	
	@ContractorId		int					-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ РєРѕРЅС‚СЂР°РіРµРЅС‚Р°
)
as
begin

	-- Р—Р°РєР°Р·
	select 
		o.ID				as 'Id',
		o.DATE				as 'CreatedDate', 	
		iif(o.PUBLICNUMBER = '', cast(o.NUMBER as nvarchar(20)), o.PUBLICNUMBER)
							as 'PublicNumber'
	from  
		ClientOrders o	
	where
		o.Id = @OrderId 

	-- РњР°СЂРєРёСЂРѕРІРєРё
	select
		p.ID					as 'Id',
		p.SKU					as 'Sku',
		m.NAME					as 'Brand',
		rtrim(p.NAME + ' ' + p.CHILDNAME)
								as 'Name',
		c.FROZENRETAILPRICE		as 'Cost',
		dm.DataMatrix			as 'DataMatrix'
	from
		OrderContentDataMatrixes dm
			left join CLIENTORDERSCONTENT c on c.CLIENTORDERID = dm.OrderId and  c.ProductId=dm.ProductId
			left join PRODUCTS p on dm.PRODUCTID = p.ID
			left join MANUFACTURERS m on m.ID = p.MANID			
	where
		dm.OrderId = @OrderId
		and c.IS_GIFT = 0
		and c.FROZENRETAILPRICE > 0		
		and dm.StateId = 1
		
	-- РљРѕРЅС‚СЂР°РіРµРЅС‚ / РєРѕРјРїР°РЅРёСЏ
	select
		c.Id		as 'ContractorId',	
		c.Inn		as 'Inn'
	from 
		Contractors c
	where 
		c.Id = @ContractorId
	
end
