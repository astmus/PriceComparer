create proc NCProductsView
(
	@Sku			int,				-- Артикул товара
	@Name			nvarchar(128),		-- Наименование товара
	@GTIN			nvarchar(14),		-- GTIN
	@SuzGTIN		nvarchar(14),		-- GTIN в СУЗ
	@HasStock		bit					-- Имеются остатки на складе
)
as
begin

	-- Временная таблица для поиска идентификаторов товаров
	create table #productIds 
	(
		Id		uniqueidentifier	not null,
		primary key (Id)
	)
	create unique index ProductIds_Id on #productIds (Id)

	-- Категории парфюмерии
	create table #perfumeryCategoriesId 
	(	
		CategoryId		uniqueidentifier	not null,
		primary key (CategoryId)
	)
	exec _fillCategoryIdsForPerfumery

	-- Для логистов
	if @SuzGTIN is not null and @SuzGTIN = 'logist' begin

		insert #productIds (Id)
		select 
			-- o.PublicNumber, p.SKU, sum(c.Quantity - isnull(dm.ScannedDMCount,0))
			--p.SKU, sum(c.Quantity - isnull(dm.ScannedDMCount,0))
			distinct p.ID
		from
			CLIENTORDERS o
			join CLIENTORDERSCONTENT c on c.CLIENTORDERID = o.ID
			join PRODUCTS p on p.ID = c.PRODUCTID
			left join 
			(
				select m.OrderId, m.ProductId, count(1) as 'ScannedDMCount'
				from OrderContentDataMatrixes m
				group by m.OrderId, m.ProductId
			) dm on dm.OrderId = o.ID and dm.ProductId = p.ID
			left join
			(
				select 
					distinct i.ProductId
				from 
					SUZOrders o
						join SUZOrderItems i on i.OrderId = o.Id
				where
					o.IsActive = 1
					and o.StatusId <> 4
					and i.IsActive = 1
			) suz on suz.ProductId = p.ID
			left join WmsShipmentDocuments d on d.PublicId = o.ID and d.DocStatus = 10
		where			
			p.VIEWSTYLEID in (1, 4)
			and p.NeedDataMatrix = 1
			and o.STATUS in (15)
			and cast(o.ExpectedDate as date) = cast(getdate() as date)
			and o.DELIVERYKIND in (1,2,3,4,6,8,18,30,32,33, 20)
			and isnull(dm.ScannedDMCount,0) < c.Quantity
			and suz.ProductId is null
			and d.PublicId is null
		/*group by 
			p.SKU
			-- o.PublicNumber, p.SKU
		having
			sum(c.Quantity - isnull(dm.ScannedDMCount,0)) > 1*/

	end else
	-- Для ТК
	if @SuzGTIN is not null and @SuzGTIN = 'tk' begin

		insert #productIds (Id)
		select 
			-- o.PublicNumber, p.SKU, sum(c.Quantity - isnull(dm.ScannedDMCount,0))
			--p.SKU, sum(c.Quantity - isnull(dm.ScannedDMCount,0))
			distinct p.ID
		from
			CLIENTORDERS o
			join CLIENTORDERSCONTENT c on c.CLIENTORDERID = o.ID
			join PRODUCTS p on p.ID = c.PRODUCTID
			left join 
			(
				select m.OrderId, m.ProductId, count(1) as 'ScannedDMCount'
				from OrderContentDataMatrixes m
				group by m.OrderId, m.ProductId
			) dm on dm.OrderId = o.ID and dm.ProductId = p.ID
			left join
			(
				select 
					distinct i.ProductId
				from 
					SUZOrders o
						join SUZOrderItems i on i.OrderId = o.Id
				where
					o.IsActive = 1
					and o.StatusId <> 4
					and i.IsActive = 1
			) suz on suz.ProductId = p.ID
			left join WmsShipmentDocuments d on d.PublicId = o.ID and d.DocStatus = 10

		where			
			p.VIEWSTYLEID in (1, 4)
			and p.NeedDataMatrix = 1
			and o.STATUS in (15)
			--and cast(o.ExpectedDate as date) = '01/10/2021'
			and o.DELIVERYKIND in (5,12,14,16,17,21,22,24,26,27,7,19,31,34)
			and isnull(dm.ScannedDMCount,0) < c.Quantity
			and suz.ProductId is null
			and d.PublicId is null
		/*group by 
			p.SKU
			-- o.PublicNumber, p.SKU
		having
			sum(c.Quantity - isnull(dm.ScannedDMCount,0)) > 1*/

	end else
	-- Для разработчиков
	if @SuzGTIN is not null and @SuzGTIN = 'skus' begin

		insert #productIds (Id)
		select 
			p.Id
		from 
			Products p
		where
			p.Sku in (371982,110574,46993,42895,392089,349839,165864,54286,55102,104182,134349,228889,127558,108404,287687,12592,254937,361276,368756,28755,16864,57291,307795,39280,125900,392085,155502,46661,375830,27675,111996,97522,8031,392153,392087,229015,246910,44127,33761,142265)
			and p.VIEWSTYLEID in (1, 4)

	end else

	-- Артикул
	if @Sku is not null begin

		insert #productIds (Id)
		select 
			p.Id
		from 
			Products p
		where
			p.Sku = @Sku
			and p.VIEWSTYLEID in (1, 4)

	end else begin

		insert #productIds (Id)
		select 
			p.Id
		from 
			Products p
		where
			(@HasStock is null or (@HasStock is not null and p.Instock > 0))
			and p.ID in
			(
				select l.PRODUCTID
				from CATEGORIESPRODUCTSLINKS l
					join #perfumeryCategoriesId c on c.CATEGORYID = l.CATEGORYID
			)
			and (@Name is null or (@Name is not null and replace(p.NAME + p.CHILDNAME,' ','') like '%' + replace(@Name,' ','') + '%'))
			and p.VIEWSTYLEID in (1, 4)

		if @GTIN is not null and @GTIN <> '' begin

			delete p
			from 
				#productIds p
					left join
					(
						select 
							b.ProductId as 'ProductId'
						from
							BarcodeProductIdLinks b
						where
							b.BarCode like '%' + @GTIN
						union
						select 
							p.ID
						from BarCodes b
							join PRODUCTS p on p.SKU = b.SKU and p.DELETED = 0
						where
							b.BarCode like '%' + @GTIN
					) b on b.ProductId = p.Id
			where
				b.ProductId is null

		end

		if @SuzGTIN is not null and @SuzGTIN <> '' begin

			delete p
			from 
				#productIds p
					left join
					(
						select 
							b.ProductId
						from
							CRPTTechCardBarcodes b
						where
							b.Barcode like '%' + @SuzGTIN
						
					) b on b.ProductId = p.Id
			where
				b.ProductId is null

		end

	end

	if exists (select 1 from #productIds) begin

		select top 5000
			p.Id					as 'Id',
			p.Sku					as 'Sku',
			m.Name					as 'Brand',
			p.Name + ' ' + p.ChildName
									as 'Name',
			isnull(b.Barcode,'')	as 'GTIN',
			p.INSTOCK				as 'Stock',
			isnull(dm.dmCount,0)	as 'DMStock',
			case 
				when o.ProductId is null then cast(0 as bit)
				else cast(1 as bit)
			end						as 'AddedToOrder'
		from 
			#productIds id
				join Products p on id.Id = p.ID
				join Manufacturers m on m.ID = p.MANID
				left join CRPTTechCardBarcodes b on b.ProductId = p.ID
				left join 
				(
					select r.ProductId, count(*) as 'dmCount'
					from DataMatrixesReceive r
						join _dataMatrixesApi a on a.DataMatrix = r.DataMatrix and a.Status = 'INTRODUCE'
					group by
						r.ProductId
				) dm on dm.ProductId = p.ID
				left join
				(
					select 
						distinct i.ProductId
					from 
						SUZOrders o
							join SUZOrderItems i on i.OrderId = o.Id
					where
						o.IsActive = 1
						and i.IsActive = 1
						--and i.GTIN = @SuzGTIN					
				) o on o.ProductId = p.ID
		where
			b.ProductId is not null
			--and isnull(dm.dmCount,0) = 0
		order by
			m.NAME, p.NAME, p.CHILDNAME

	end

end
