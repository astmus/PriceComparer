create proc CompetitorFeedItemsForMatchView
(
	@FeedId			int,				-- Идентификатор фида
	@Symbol			varchar(1),			-- Первая буква бренда
	@Brand			varchar(255),		-- Наименование бренда
	@ProductName	varchar(255),		-- Наименование товара
	@TotalCount		int out				-- Количество. найденное по поиску
) as
begin
	
	set @TotalCount = 0

	declare @limit int = 100

	create table #ids
	(
		Id			int			not null,
		RowNo		int			not null,
		primary key (Id)
	)
		
	insert #ids (Id, RowNo)
	select
		i.Id, row_number() over (order by i.Vendor, i.Name, i.Model)
	from
		CompetitorsFeedItems i
		left join CompetitorsFeedProductLinks l on l.FeedItemId = i.Id
	where
		i.FeedId = @FeedId
		and l.FeedItemId is null
		and i.IsUsed = 1
		and i.Deleted = 0
		and 
		(
			(
				@Symbol is not null 
				and 
				i.Vendor like (@Symbol + '%')
			)
			or
			(
				@Symbol is null 
				and
				(
					(@Brand is null or (@Brand is not null and i.Vendor like '%' + @Brand + '%'))
					and
					(@ProductName is null or (@ProductName is not null and i.Name like ('%' + @ProductName + '%')))
				)
			)
		)

	select @TotalCount = count(1) from #ids

	select 		
		-- Позиция в фиде
		i.Id							as 'Id',
		isnull(i.OuterSku,'')			as 'Sku',
		i.OuterId						as 'OuterId',
		isnull(i.Vendor,'')				as 'Brand',
		i.Name							as 'ProductName',
		isnull(i.[Model],'')			as 'Model',
		isnull(i.Details,'')			as 'Details',
		isnull(i.Sex,'')				as 'Sex',
		isnull(i.[Year],'')				as 'Year',
		case
			when i.[Description] is null
				then ''
			when len(i.[Description]) < 100
				then i.[Description]
			else
				substring(i.[Description], 0, 100) + '...'
		end
										as 'Description',
		isnull(i.PhotoUrl,'')			as 'PhotoUrl',
		isnull(i.ProductUrl,'')			as 'ProductUrl',
		i.Available						as 'Available'
	from
		#ids id
		join CompetitorsFeedItems i on id.Id = i.Id
	where
		id.RowNo <= @limit
	order by
		id.RowNo

end
