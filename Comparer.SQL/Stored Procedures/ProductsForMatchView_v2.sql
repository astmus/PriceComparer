create proc ProductsForMatchView_v2
(
	@Sku				int,				-- Артикул товара
	@Brand				varchar(255),		-- Наименование бренда
	@ProductName		varchar(255),		-- Наименование товара
	@ConсentrationId	int,				-- Идентификатор концентрации
	@Volume				varchar(10),		-- Объем
	@KindId				int,				-- Идентификатор вида (не из таблицы Products)
											-- 1 - Миниатюры
											-- 2 - Пробники
											-- 3 - Уценка
											-- 4 - Наборы
	@TotalCount			int out				-- Количество. найденное по поиску
) as
begin
	
	set @TotalCount = 0

	create table #ids
	(
		Id					uniqueidentifier	not null,
		Brand				varchar(255)		not null,
		ConcentrationName	varchar(255)		not null,
		VolumeName			varchar(255)		not null,
		RowNo				int					not null,
		primary key (Id, RowNo)
	)
		
	if @Sku is not null begin

		insert #ids (Id, Brand, ConcentrationName, VolumeName, RowNo)
		select
			p.Id, m.NAME, isnull(v.FV_NAME,''), '', 1
		from
			Products p
			join Manufacturers m on m.ID = p.MANID
			left join ProductsFeatures pf on pf.ProductId = p.ID and pf.FeatureId = 15		-- Концентрация		
			left join FEATUREVALUES v on v.VALUEID = pf.VALUEID				
		where
			p.Deleted = 0
			and m.IsDeleted = 0
			and p.ViewStyleId in (1, 4)
			and p.SKU = @Sku

	end else begin
	
		insert #ids (Id, Brand, ConcentrationName, VolumeName, RowNo)
		select
			p.Id, m.NAME, isnull(v.FV_NAME,''), '',			
			row_number() over (order by m.Name, p.FullName)
		from
			Products p
			join Manufacturers m on m.ID = p.MANID
			left join ProductsFeatures pf on pf.ProductId = p.ID and pf.FeatureId = 15		-- Концентрация		
			left join FEATUREVALUES v on v.VALUEID = pf.VALUEID		
			left join ProductsFeatures pfp on pfp.ProductId = p.ID and pfp.FeatureId = 13		-- Пробник
			left join ProductsFeatures pfm on pfm.ProductId = p.ID and pfm.FeatureId = 17		-- Миниатюра			
		where
			p.Deleted = 0
			and m.IsDeleted = 0
			and p.ViewStyleId in (1, 4)
			and 
			(
				(@Brand is null or (@Brand is not null and m.NAME like '%' + @Brand + '%'))
				and
				(@ProductName is null or (@ProductName is not null and p.FullName like ('%' + @ProductName + '%')))
				and
				(@Volume is null or (@Volume is not null and p.CHILDNAME like ('%' + @Volume + '[^0-9]%')))
			)
			and -- Концентрация
			(
				@ConсentrationId is null
				or
				(
					@ConсentrationId is not null
					and
					pf.ProductId is not null
					and
					pf.ValueId = @ConсentrationId
				)
			)
			and
			(
				@KindId is null
				or
				(
					@KindId is not null 
					and
					(
						(@KindId = 1 and pfm.ProductId is not null)
						or
						(@KindId = 2 and pfp.ProductId is not null)
						or
						(@KindId = 3 and p.TESTER = 1)
						or
						(@KindId = 4 and p.FullName like '%набор%')
					)
				)
			)

	end

	select @TotalCount = count(1) from #ids

	select 		
		-- Позиция в фиде
		p.Id							as 'Id',
		p.Sku							as 'Sku',
		p.Published						as 'IsActive',
		id.Brand						as 'Brand',
		p.FullName						as 'ProductFullName',
		p.Name							as 'ProductName',
		p.ChildName						as 'ProductChildName',
		id.ConcentrationName			as 'ConcentrationName',
		isnull(vv.FV_NAME,'')			as 'VolumeName',
		p.COMMENT						as 'Comment',
		isnull(par.Comment,'')			as 'ParentComment',
		isnull(par.SKU, -1)				as 'ParentSku',
		case isnull(pfs.ValueId, '')
			when 5 then 'Ж'
			when 6 then 'М'
			when 7 then 'У'
			else ''
		end								as 'Sex',
		isnull(vy.FV_NAME, '')			as 'Year'
	from
		#ids id
		join PRODUCTS p on id.Id = p.Id
		left join ProductsProducts pp on pp.ChildId = p.ID
		left join PRODUCTS par on par.ID = pp.ParentId and par.ViewStyleId = 2
		left join ProductsFeatures pfv on pfv.ProductId = p.ID and pfv.FeatureId = 16	-- Объем
		left join FEATUREVALUES vv on vv.VALUEID = pfv.VALUEID
		left join ProductsFeatures pfs on pfs.ProductId = par.ID and pfs.FeatureId = 11	-- Пол
		left join ProductsFeatures pfy on pfy.ProductId = par.ID and pfy.FeatureId = 3	-- Год
		left join FEATUREVALUES vy on vy.VALUEID = pfy.VALUEID
	where
		id.RowNo <= 100
	order by
		id.RowNo

end
