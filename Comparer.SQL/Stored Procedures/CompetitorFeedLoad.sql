create proc CompetitorFeedLoad 
(
	@FeedId int,
	@LoadDate	datetime
	--@AuthorId uniqueidentifier
) as
begin

	set nocount on

	create index ix_items_OuterId on #Items (OuterId)

   -- РћР±СЉСЏРІР»СЏРµРј РїРµСЂРµРјРµРЅРЅС‹Рµ

	declare @trancount int,					-- РљРѕР»-РІРѕ РѕС‚РєСЂС‹С‚С‹С… С‚СЂР°РЅР·Р°РєС†РёР№

			@RowsImported int,		        -- РљРѕР»РёС‡РµСЃС‚РІРѕ РёРјРїРѕСЂС‚РёСЂРѕРІР°РЅРЅС‹С… Р·Р°РїРёСЃРµР№
			@RowsAllCount int,              -- РћР±С‰РµРµ РєРѕР»РёС‡РµСЃС‚РІРѕ Р·Р°РїРёСЃРµР№
			@RowsChanged int,		        -- РљРѕР»РёС‡РµСЃС‚РІРѕ РёР·РјРµРЅРµРЅРЅС‹С… Р·Р°РїРёСЃРµР№
			@RowsNew int,			        -- РљРѕР»-РІРѕ РЅРѕРІС‹С… Р·Р°РїРёСЃРµР№
			@RowsDeleted int		        -- РљРѕР»РёС‡РµСЃС‚РІРѕ СѓРґР°Р»РµРЅРЅС‹С… Р·Р°РїРёСЃРµР№

		-- РћРїСЂРµРґРµР»СЏРµРј РєРѕР»РёС‡РµСЃС‚РІРѕ Р·Р°РїРёСЃРµР№ РІ Р·Р°РіСЂСѓР¶Р°РµРјРѕРј С„РёРґРµ
		select @RowsAllCount=count(1) from #Items;

		-- Р’С‹РїРѕР»РЅСЏРµРј СЃРѕС…СЂР°РЅРµРЅРёРµ РІ Р‘Р”
		begin try

		select @trancount = @@TRANCOUNT

     	-- РћС‚РєСЂС‹Р»Рё С‚СЂР°РЅР·Р°РєС†РёСЋ, РµСЃР»Рё РµС‰Рµ РЅРµ РѕС‚РєСЂС‹С‚Р°
		if @trancount = 0
			begin transaction

        -- РЎР±СЂР°СЃС‹РІР°РµРј СЃРѕСЃС‚РѕСЏРЅРёРµ Р·Р°РїРёСЃРµР№ РІ Р±Р°Р·Рµ РґР°РЅРЅС‹С…
		update CompetitorsFeedItems
		set Deleted=1
		from CompetitorsFeedItems
		where FeedId=@FeedId

		 -- РћР±РЅРѕРІР»СЏРµРј СЃСѓС‰РµСЃС‚РІСѓСЋС‰РёРµ Р·Р°РїРёСЃРё
		update i
		set
			i.Deleted = 0,
			i.OuterSku = isnull(f.OuterSku,i.OuterSku),
			i.OuterBarcode = isnull(f.OuterBarcode,i.OuterBarcode),	
			i.OuterChangedDate = isnull(f.OuterChangedDate,i.OuterChangedDate),	
			i.Name = f.Name,
			i.Model = isnull(f.Model,i.Model), 
			i.Description = isnull(f.Description,i.Description),	
			i.Details = isnull(f.Details,i.Details),	
			i.TypeId = isnull(f.TypeId,i.TypeId),	
			i.GroupId = isnull(f.GroupId,i.GroupId),		
			i.CategoryId = isnull(f.CategoryId,i.CategoryId),	
			i.PhotoUrl = isnull(f.PhotoUrl,i.PhotoUrl),		
			i.ProductUrl = isnull(f.ProductUrl,i.ProductUrl),		
			i.CurrencyId = isnull(f.CurrencyId,i.CurrencyId),		
			i.Price = isnull(f.Price,i.Price),			
			i.OldPrice = isnull(f.OldPrice,i.OldPrice),			
			i.Vendor = isnull(f.Price,i.Price),			
			i.VendorCode = isnull(f.VendorCode,i.VendorCode),			
			i.Available	= isnull(f.Available,i.Available),			
			i.PickupAvailable = isnull(f.PickupAvailable,i.PickupAvailable),			
			i.DeliveryAvailable	= isnull(f.DeliveryAvailable,i.DeliveryAvailable),			
			i.DeliveryDetails = isnull(f.DeliveryDetails,i.DeliveryDetails),				
			i.ChangedDate = @LoadDate
		from #Items f
			join CompetitorsFeedItems i on i.FeedId=@FeedId and i.OuterId=f.OuterId

		-- РћРїСЂРµРґРµР»СЏРµРј РєРѕР»-РІРѕ РѕР±РЅРѕРІР»РµРЅРЅС‹С… Р·Р°РїРёСЃРµР№
		select @RowsChanged = @@RowCount
	
		 -- Р’СЃС‚Р°РІР»СЏРµРј РЅРѕРІС‹Рµ Р·Р°РїРёСЃРё
		insert CompetitorsFeedItems 
		(
		 	FeedId, OuterId, OuterSku, OuterBarcode, OuterChangedDate,
			Name, Model, Description, Details,
			TypeId, GroupId, CategoryId,
			PhotoUrl, ProductUrl,
			CurrencyId,	Price, OldPrice,
			Vendor, VendorCode,
			Available, 	PickupAvailable, DeliveryAvailable, DeliveryDetails,
			ChangedDate
		)
		select 
		 	@FeedId, f.OuterId, f.OuterSku, f.OuterBarcode, f.OuterChangedDate,
			f.Name, f.Model, f.Description, f.Details,
			isnull(f.TypeId,0), isnull(f.GroupId,0), isnull(f.CategoryId,0),
			f.PhotoUrl, f.ProductUrl,
			isnull(f.CurrencyId,1),	f.Price, f.OldPrice,
			f.Vendor, f.VendorCode,
			isnull(f.Available,1), f.PickupAvailable, f.DeliveryAvailable, f.DeliveryDetails,
			@LoadDate
		from #Items f
			left join  CompetitorsFeedItems i on i.FeedId=@FeedId and i.OuterId=f.OuterId
		where 
			i.Id is null

		-- РћРїСЂРµРґРµР»СЏРµРј РєРѕР»-РІРѕ РЅРѕРІС‹С… Р·Р°РїРёСЃРµР№
		select @RowsNew = @@RowCount

		-- РћРїСЂРµРґРµР»СЏРµРј РєРѕР»-РІРѕ РЅРµ Р°РєС‚РёРІРЅС‹С… Р·Р°РїРёСЃРµР№
		select @RowsDeleted = sum( case when Deleted=1 then 1 else 0 end)
		from  CompetitorsFeedItems  
		where FeedId = @FeedId

		set @RowsImported= @RowsChanged + @RowsNew

		-- Р•СЃР»Рё РєР°РєРёРµ-Р»РёР±Рѕ РёР·РјРµРЅРµРЅРёСЏ РІС‹РїРѕР»РЅРµРЅС‹,
		-- С‚Рѕ РёР·РјРµРЅСЏРµРј РґР°С‚Сѓ Р·Р°РіСЂСѓР·РєРё РїСЂР°Р№СЃ-Р»РёСЃС‚Р°
		if @RowsChanged > 0 or @RowsNew > 0 or @RowsDeleted > 0
		begin
			update c
			set 
				c.LastLoadDate=@LoadDate
			from CompetitorsFeeds  c
			  where c.Id = @FeedId
		end 

		if @trancount = 0
			commit transaction

		-- Р’С‹РІРѕРґРёРј СЂРµР·СѓР»СЊС‚Р°С‚С‹ Р·Р°РіСЂСѓР·РєРё РїСЂР°Р№СЃ-Р»РёСЃС‚Р°
select	
			@FeedId						as 'FeedId',
			isnull(@RowsAllCount,0)		as 'RowsAllCount',           
			isnull(@RowsImported,0)		as 'RowsImported',                
			isnull(@RowsNew,0)			as 'RowsNew',            
			isnull(@RowsChanged,0)		as 'RowsChanged',               
			isnull(@RowsDeleted,0)		as 'RowsDeleted',        
			   
			@LoadDate					as 'LastLoadData',
			null						as 'ResultMessage'						

		return 0
	end try 

	begin catch 
		if @trancount = 0
			rollback transaction
	select
			@FeedId						as 'FeedId',
			isnull(@RowsAllCount,0)		as 'RowsAllCount',           
			isnull(@RowsImported,0)		as 'RowsImported',                
			isnull(@RowsNew,0)			as 'RowsNew',            
			isnull(@RowsChanged,0)		as 'RowsChanged',               
			isnull(@RowsDeleted,0)		as 'RowsDeleted',        
			   
			@LoadDate					as 'LastLoadData',
			null						as 'ResultMessage'						

		return 1
	end catch 
	
end
