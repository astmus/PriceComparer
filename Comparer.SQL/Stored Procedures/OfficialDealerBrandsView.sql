create proc OfficialDealerBrandsView
(
	@DistributorId			uniqueidentifier		--Идентификатор поставщика
) as
begin
	
		select 
			m.Id as 'Id',
			m.Name as 'Name',
			m.ExtraUsed as 'ExtraUsed',
			m.Extra as 'Extra',
			m.Description as 'Description',
			m.Published as 'Published',
			m.ALLOWFORDISCOUNTS as 'AllowForDiscounts',
			m.DefaultCurrency as 'DefaultCurrency',
			m.CurrencyRate as 'CurrencyRate',
			m.UseInWholeSalePriceList as 'UseInWholeSalePriceList',
			m.CountryAlpha3Code as 'CountryAlpha3Code',
			m.IsDeleted as 'IsDeleted',
			m.CreatedDate as 'CreatedDate',
			m.ChangedDate as 'ChangedDate'
		from Manufacturers m
			join MainDistributorForBrandLinks l on m.ID = l.BrandId
		where
			(@DistributorId is null or l.DistributorId = @DistributorId)
		order by m.NAME

end
