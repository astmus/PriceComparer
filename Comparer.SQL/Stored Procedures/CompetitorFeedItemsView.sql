create proc CompetitorFeedItemsView
(
	@FeedId				int,				-- Идентификатор фида
	@ItemName			varchar(255),		-- Наименование позиции
	@Vendor				varchar(255),		-- Наименование бренд
	@UsedState			bit,				-- Состояние использования
	@LinkState			bit,				-- Состояние сопоставления

	@Limit				int,				-- Кол-во строк
	@Offset				int,				-- Смещение
	@OrderBy			varchar(255),		-- Поле для сортировки
	-- Выходные параметры
	@TotalCount			int out				-- Общее кол-во записей, удовлетворяющих условиям
) as
begin
	
	set @TotalCount = 0

	-- Таблица для идентификаторов товаров
	create table #ids
	(
		Id		int		not null,
		RowNo	int		not null,
		primary key (Id)
	)

	-- Заполняем таблицу
	if @OrderBy = 'Name' begin

		insert #Ids (Id, RowNo)
		select 
			i.Id, 
			row_number() over (order by i.Name)
		from  
			CompetitorsFeedItems i
			left join (select distinct l.FeedItemId from CompetitorsFeedProductLinks l) l on l.FeedItemId = i.Id
		where 
			i.FeedId = @FeedId 
			and (@Vendor is null or (@Vendor is not null and i.Vendor like '%' + @Vendor + '%'))
			and (@ItemName is null or (@ItemName is not null and i.Name like '%' + @ItemName + '%'))
			and (@UsedState is null or (@UsedState is not null and i.IsUsed = @UsedState))
			and (@LinkState is null or (@LinkState is not null and ((@LinkState = 1 and l.FeedItemId is not null) or (@LinkState = 0 and l.FeedItemId is null))))

	end
	
	-- Получаем общее кол-во записей
	select @TotalCount = count(1) from #Ids

	-- Выводим результат
	select
		f.Id,
		f.FeedId,
		f.Deleted,
		f.IsUsed,
		f.OuterId,
		f.OuterSku,
		f.OuterBarcode,
		f.OuterChangedDate,
		f.Name					as 'ItemName',
		f.[Model],
		f.[Description],
		f.Details,
		f.TypeId,
		f.GroupId,
		f.CategoryId,
		f.PhotoUrl,
		f.ProductUrl,
		f.CurrencyId,
		c.ShortName				as 'CurrencyName',
		f.Price,
		f.OldPrice,
		f.Vendor,
		f.VendorCode,
		f.Available,
		f.PickupAvailable,
		f.DeliveryAvailable,
		f.DeliveryDetails,
		f.ChangedDate,
		f.CreatedDate,
		-- Товар 
		p.ID					as 'ProductId',
		p.SKU					as 'InnerSku',
		p.FullName				as 'ProductName',
		m.NAME					as 'BrandName'
	from #Ids i
		join CompetitorsFeedItems f on i.Id = f.Id
		left join CompetitorsFeedProductLinks l on l.FeedItemId = i.Id
		left join Products p on p.ID = l.ProductId
		left join MANUFACTURERS m on m.ID = p.ManId
		left join CURRENCIES c on c.CurrencyId = f.CurrencyId
	where
		i.RowNo > @Offset 
		and i.RowNo <= (@Offset + @Limit)
	order by
		i.RowNo
end
