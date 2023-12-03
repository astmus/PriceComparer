create proc SyncSiteProductPriceView
(
	@ProductId			uniqueidentifier,		-- Идентификатор товара
	@SiteId				uniqueidentifier		-- Идентификатор сайта
) as
begin

	select 
		p.ID									as 'ProductId',
		p.SKU									as 'Sku',
		p.VIEWSTYLEID							as 'ViewStyleId',
		s.ID									as 'SiteId',
		s.NAME									as 'SiteName',
		s.HOST									as 'SiteHost',
		s.DataBusSync							as 'DataBusSync',
		sp.SP_RETAILPRICE						as 'PriceCalc',
		sp.SP_RECOMMENDEDRETAILPRICE			as 'PriceRRC',
		isnull(sp.SP_HandFixedRetailPrice,0)	as 'PriceHandFixed',
		sp.SP_WITHDISCOUNT						as 'Price',
		sp.SP_PrevFinalPrice					as 'PrevPrice',
		sale.SaleControlType					as 'SaleControlType',
		sale.SaleState							as 'SaleState',
		d.ID									as 'DiscountId',
		d.PUBLICGUID							as 'DiscountGuid',
		d.NAME									as 'DiscountName',
		d.ACTIONS								as 'DiscountActions',
		isnull(z.RetailPrice,0)					as 'LastPrice'
	from SITEPRODUCTS sp
		join SITES s on s.ID = sp.SITEID  and sp.SITEID = @SiteId
		join PRODUCTS p on p.ID = sp.PRODUCTID and sp.PRODUCTID = @ProductId
		join ProductsSale sale on sale.ProductId = p.ID
		left join DISCOUNTS d on d.ID = sp.SP_DISCOUNTID
		left join LastNoZeroRetailPrices z on z.SiteId = sp.SiteId and z.ProductId = sp.ProductId
	
end
