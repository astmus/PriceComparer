create proc CompetitorsFeedItemsHistoryView
(
	@AuthorId			uniqueidentifier,	-- Идентификатор автора
	@OperationId		int,				-- Идентификатор операции
	@ProductName		varchar(255),		-- Наименование товара
	@MoreThenId			int					-- Вывести записи с Id больше указанного
) as
begin
	
	declare 
		@today date = getdate()

	select 	
		-- История
		h.Id							as 'Id',
		h.AuthorId						as 'AuthorId',
		h.OperationId					as 'OperationId',
		op.Name							as 'OperationName',
		h.CreatedDate					as 'CreatedDate',

			
		-- Позиция в фиде
		i.Id							as 'ItemId',
		i.Vendor						as 'ItemBrandName',
		i.Name							as 'ItemName',
		isnull(i.Details, '')			as 'ItemDetails',
		isnull(i.PhotoUrl, '')			as 'ItemPhotoUrl',
		isnull(i.ProductUrl, '')		as 'ItemProductUrl',

		-- Товар в ShopBase
		p.Id							as 'ProductId',
		p.Sku							as 'ProductSku',
		p.Published						as 'ProductIsActive',
		isnull(m.Name,'')				as 'ProductBrandName',		
		isnull(p.Name,'')				as 'ProductName',
		isnull(p.ChildName,'')			as 'ProductChildName',
		isnull(p.COMMENT,'')			as 'ProductComment',

		-- Товар-родитель
		par.Id							as 'ParentId',
		par.Sku							as 'ParentSku',
		isnull(par.Comment,'')			as 'ParentComment'
	from
		CompetitorsFeedItemsHistory h
		join CompetitorsFeedItemsOperations op on op.Id = h.OperationId
		join CompetitorsFeedItems i on i.Id = h.FeedItemId
		left join PRODUCTS p on h.ProductId = p.Id
		left join MANUFACTURERS m on m.ID = p.ManId
		left join ProductsProducts pp on pp.ChildId = p.ID
		left join PRODUCTS par on par.ID = pp.ParentId and par.ViewStyleId = 2
	where
		cast(h.CreatedDate as date) = @today
		and h.AuthorId = @AuthorId
		and (@MoreThenId is null or (@MoreThenId is not null and h.Id > @MoreThenId))
	order by
		h.CreatedDate desc

end
