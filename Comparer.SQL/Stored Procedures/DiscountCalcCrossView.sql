create proc DiscountCalcCrossView
(
	@CalcId			int		-- скидка
)
as
begin

	if @CalcId = 0
		select @CalcId = Max(Id) from RetailPricesCalcHistory where	StatusId = 1

	create table #ccross (ProductId uniqueidentifier, DiscountId int, RowNum int)

	insert into #ccross
	select
		ProductId, DiscountId,
		ROW_NUMBER() OVER (PARTITION by ProductId ORDER BY DiscountId) as 'RowNum'
	from
		DiscountCalcArchive
	where
		CalcId = @calcId


	select
		p.SKU					as 'Sku',
		p.ID					as 'ProductId',
		p.FullName				as 'ProductName',
		man.Name				as 'BrandName',
		sp.sp_discountid		as 'SPDiscountId',
		d.Name					as 'Discount',
		d.[Priority]			as 'Priority',
		ca.DISCOUNTID			as 'Discount1Id'
		, d1.[PRIORITY]			as 'Priority1'
		, isnull(d1.NAME, '')	as 'Discount1'
		, c2.DiscountId			as 'Discount2Id'
		, d2.[PRIORITY]			as 'Priority2'
		, isnull(d2.NAME, '')	as 'Discount2'
		, c3.DiscountId			as 'Discount3Id'
		, d3.[PRIORITY]			as 'Priority3'
		, isnull(d3.NAME, '')	as 'Discount3'
	from
		#ccross ca
		JOIN PRODUCTS p			ON ca.ProductId = p.ID
		JOIN SiteProducts sp	ON p.ID = sp.ProductId AND sp.siteid = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'
		JOIN MANUFACTURERS man	ON p.manId = man.ID
		JOIN DISCOUNTS d		ON sp.sp_discountid = d.ID
		JOIN DISCOUNTS d1		ON ca.discountId = d1.ID
		JOIN #ccross c2			ON ca.ProductId = c2.ProductId AND c2.RowNum = 2
		JOIN DISCOUNTS d2		ON c2.discountId = d2.ID
		LEFT JOIN #ccross c3	ON ca.ProductId = c3.ProductId AND c3.RowNum = 3
		LEFT JOIN DISCOUNTS d3	ON c3.discountId = d3.ID
	where
		ca.RowNum = 1
	order by
		ProductName

end
