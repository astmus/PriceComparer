create proc MonoBrand
as
begin
	set nocount on
	
	begin try
	declare @Query nvarchar(max), @ColumnNames nvarchar(max), @ColumnNamesHeader nvarchar(max)

	declare @Cource float
	select @Cource = RateValue from DailyCurrencies where CharCode='USD'

	create table #Result1
	(	BrandName		varchar(255)	not null,
		Sku				int				not null,
		DistributorName	varchar(255)	not null,
		ProductName		varchar(2048)	not null,
		Price			float			not	null,
		primary key (BrandName, sku, DistributorName))

	insert #Result1 (BrandName, sku, DistributorName, ProductName, Price)
	select 	J.NAME, pr.sku, F.NAME, max(iif(pr.VIEWSTYLEID = 4, pr.NAME + ' ' + pr.CHILDNAME, pr.NAME)),
			max(case when E.DEFAULTCURRENCY=1 then round(D.PRICE/@Cource,2) else D.PRICE end)
	from #MonoBrands A
	join PRODUCTS pr on pr.MANID = A.Id
	join LINKS C with (index (LINKSPRIMARY)) on C.CATALOGPRODUCTID=pr.ID
	join PRICESRECORDS D on D.RECORDINDEX=C.PRICERECORDINDEX and D.DELETED=0 and D.USED=1 and D.PRICE>0
	join PRICES E with (index (PRICESPRIMARY)) on E.ID=D.PRICEID and E.ISACTIVE=1
	join DISTRIBUTORS F with (index (DISTRIBUTORSPRIMARY)) on F.ID=E.DISID and F.ACTIVE=1 and (F.GOINPURCHASELIST=1  or F.GOINPURCHASELIST=0 and F.id='2EB24767-1D46-4EA3-A02E-BCC626CB9DCD') 
	left join DistributorFreeDays G with (index (1)) on G.DISTRIBUTORID=E.DISID and G.FREEDAY=cast(getdate() as date)
	join MANUFACTURERS J with (index (1)) on J.ID=pr.MANID
	where (pr.VIEWSTYLEID=1 or pr.VIEWSTYLEID=4) and pr.DELETED=0 and G.DISTRIBUTORID is null
	group by J.NAME, pr.sku, F.NAME
	
	create table #ColumnNames
	(	ColumnName nvarchar(100) not null, 
		primary key (ColumnName))

	insert #ColumnNames (ColumnName) select distinct DistributorName from #Result1
		
	select @ColumnNames = ISNULL(@ColumnNames + ', ','') + QUOTENAME(ColumnName) 
	from #ColumnNames;
/*
	select @ColumnNamesHeader = ISNULL(@ColumnNamesHeader + ', ','') 
									+ 'COALESCE('
									+ QUOTENAME(ColumnName) 
									+ ', 0) AS '
									+ QUOTENAME(ColumnName)
	from #ColumnNames;
*/
	select @ColumnNamesHeader = ISNULL(@ColumnNamesHeader + ', ','') + QUOTENAME(ColumnName) from #ColumnNames

		--Р¤РѕСЂРјРёСЂСѓРµРј СЃС‚СЂРѕРєСѓ СЃ Р·Р°РїСЂРѕСЃРѕРј PIVOT
	set @Query = N'select BrandName, ProductName, sku , ' + @ColumnNamesHeader + ' 
				   from (select BrandName, ProductName, sku, DistributorName, Price ' +
						 ' from #Result1) SRC
				   PIVOT ( max(Price) for DistributorName in (' + @ColumnNames + ')) PVT'
		
		--Р’С‹РїРѕР»РЅСЏРµРј СЃС‚СЂРѕРєСѓ Р·Р°РїСЂРѕСЃР° СЃ PIVOT
	exec (@Query);

-- select * from #Result1 order by BrandName, ProductName, sku
	
		return 0

	end try
	begin catch		
		return 1
	end catch

end


-- 
/*
insert #MonoBrands (Id)
values ('EB1CAE7E-2555-49CA-9222-000A4E6A5DB5'),
('147B398B-85B9-42C3-964D-003000C6539E'),
('64AB5FC7-B763-4A0B-9C37-00585BF8BC87'),
('19CD7D50-FCE5-4294-ACC9-0096B49711C3'),
('C0BDDB26-4BE0-4506-881D-00A1F43E317A'),
('ADCD4732-3FC7-480C-A195-00DF72A19CA5'),
('7085B5CA-FA5D-470A-9754-0115FAA48B45'),
('2B20937B-5F32-444D-8D8C-01260BFB987E'),
('F776D6DF-FE85-4F9F-825D-014CE5E3224B'),
('4ABB4495-B431-4952-A679-018082489864')

	exec MonoBrand
*/
