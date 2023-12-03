create proc CalcAffectedProducts as
begin

	set nocount on

	create table #discounts(
		DiscountId int,
		ProductsCount int
	)

	begin try

		insert into #discounts
		select
			SP_DISCOUNTID, COUNT(1) as 'cnt'
		from
			SiteProducts
		where
			SITEID = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'
			AND SP_DISCOUNTID is Not Null
		group by
			SP_DISCOUNTID


		update d set
			AffectedProductsCount = t.ProductsCount
		from
			DISCOUNTS d
			JOIN #discounts t ON d.ID = t.DiscountId

		return 0
	end try 
	begin catch 
		return 1
	end catch 	

end
