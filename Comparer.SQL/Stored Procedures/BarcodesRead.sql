create procedure BarcodesRead as
begin
	
	set nocount on
	
	begin try  
		insert BarCodesSession (SessionBegin, SourceType)
		values (getdate(), 1)

		declare @session int
		select @session = @@identity

		declare @Batch1C table
		(	BatchNo			nchar(10)			not	null,
			primary key (BatchNo))

		insert @Batch1C (BatchNo)
		select distinct [РќРѕРјРµСЂРџРѕСЃС‹Р»РєРё] 
		from IM..[РўРµРєСѓС‰РёРµРЁС‚СЂРёС…РєРѕРґС‹] 
		-- РџРµСЂРµРїРёСЃР°Р» 19.10.2018 РёР·-Р·Р° С‚РѕРіРѕ, С‡С‚Рѕ РёР· 1РЎ СЃС‚Р°Р»Рё РїСЂРёС…РѕРґРёС‚СЊ РЅРѕРјРµСЂР° РїР°СЂС‚РёР№ СЃРѕ СЃС‚СЂР°РЅРЅС‹РјРё СЃРёРјРІРѕР»Р°РјРё :)
		--where [РќРѕРјРµСЂРџРѕСЃС‹Р»РєРё]>isnull((select max(BatchNo) from BarCodesSessionBatches),0)
		where convert(int, dbo.fn_StripCharacters([РќРѕРјРµСЂРџРѕСЃС‹Р»РєРё], '^0-9')) > isnull((select max(convert(int, dbo.fn_StripCharacters(BatchNo, '^0-9'))) from BarCodesSessionBatches), 0)

		declare @BatchNo char(10), @RetValue int
		declare BatchCursor cursor for select BatchNo from @Batch1C order by BatchNo
		open BatchCursor
		fetch next from BatchCursor into @BatchNo
		while @@FETCH_STATUS = 0
		begin
			exec @RetValue=Barcodes1CBatchRead @session, @BatchNo
			if @RetValue =  1 return 1
			fetch next from BatchCursor into @BatchNo
		end 
		close BatchCursor
		deallocate BatchCursor

		exec @RetValue=BarcodesPriceRead @session
		if @RetValue =  1 return 1
		
		return 0
	end try
	begin catch 
		
		return 1
	end catch 
	
end
