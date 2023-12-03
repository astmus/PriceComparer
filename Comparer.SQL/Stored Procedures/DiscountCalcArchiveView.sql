create proc DiscountCalcArchiveView
(
	@DiscountId			int		-- скидка
)
as
begin
	declare @calcId int

	select @calcId = MAX(Id) from RetailPricesCalcHistory where
		StatusId = 1

	select
		p.SKU				as 'Sku',
		p.ID				as 'ProductId',
		p.FullName			as 'ProductName',
		ca.DISCOUNTID		as 'DiscountId',
		man.Name			as 'BrandName',
		d.Name				as 'Discount',
		d.[Priority]		as 'Priority',
		sp.sp_discountid	as 'SPDiscountId'
	from
		DiscountCalcArchive ca
		JOIN PRODUCTS p			ON ca.ProductId = p.ID
		JOIN SiteProducts sp	ON p.ID = sp.ProductId AND sp.siteid = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'
		JOIN MANUFACTURERS man	ON p.manId = man.ID
		JOIN DISCOUNTS d		ON ca.DiscountId = d.ID
	where
		CalcId = @calcId
		AND DiscountId = @DiscountId
end
