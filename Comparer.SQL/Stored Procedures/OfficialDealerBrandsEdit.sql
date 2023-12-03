create proc OfficialDealerBrandsEdit
(
	@DistributorId			uniqueidentifier		--Идентификатор поставщика
) as
begin
	begin try

		--1. Удаляем в MainDistributorForBrandLinks имеющиеся привязанные бренды
		delete MainDistributorForBrandLinks  where DistributorId = @DistributorId
		
		--2. Привязывем новые 
		if exists (select 1 from #BrandIds ) begin
			insert MainDistributorForBrandLinks (DistributorId, BrandId)
			select  @DistributorId, b.Id from #BrandIds b 
		end

		return 0
	end try
	begin catch
		return 1
	end catch
end
