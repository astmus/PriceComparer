create proc DeliveryServiceStatusesUpdate_v2
(
	@AccountId	int,					-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ Р°РєРєР°СѓРЅС‚Р°
	@OuterId	nvarchar(50),			-- Р’РЅРµС€РЅРёР№ РЅРѕРјРµСЂ Р·Р°РєР°Р·Р°
		--
	@ErrorMes	nvarchar(4000) out		-- РЎРѕРѕР±С‰РµРЅРёРµ РѕР± РѕС€РёР±РєР°С…
)
as
begin

	set nocount on;
	set @ErrorMes = ''

	if not exists (select 1 from #ordersStatuses)
		return 0

	begin try
			
		-- РќРѕРІС‹Р№ СЃС‚Р°С‚СѓСЃ СЃ РјР°РєСЃРёРјР°Р»СЊРЅРѕР№ РґР°С‚РѕР№
		declare 
			@LastStatusId		int,				-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ СЃС‚Р°С‚СѓСЃР°
			@LastStatusDate		datetime,			-- РґР°С‚Р° СЃС‚Р°С‚СѓСЃР°
			@StatusDescription	nvarchar(500)		-- РѕРїРёСЃР°РЅРёРµ

		-- Р’С‹Р±РёСЂР°РµРј СЃС‚Р°С‚СѓСЃ РјР°РєРёРјР°Р»СЊРЅС‹Р№ РїРѕ РґР°С‚Рµ Рё...
		select 
			top 1  
			@LastStatusId		= StatusId, 
			@LastStatusDate		= StatusDate,
			@StatusDescription	= [Description]
		from 
			#ordersStatuses
		order by 
			StatusDate desc

		-- ... СѓРґР°Р»СЏРµРј РёР· РІСЂРµРјРµРЅРЅРѕР№ С‚Р°Р±Р»РёС†С‹
		delete 
			#ordersStatuses
		where  
			StatusId	= @LastStatusId and
			StatusDate	= @LastStatusDate

		-- РўРµРєСѓС‰РёР№ СЃС‚Р°С‚СѓСЃ
		declare 
			@innerId			uniqueidentifier,	
			@currStatus			int,
			@currStatusDate		datetime,
			@currDescription	nvarchar(500)

		select 
			@innerId			= dso.InnerId,
			@currStatus			= dso.StatusId, 
			@currStatusDate		= isnull(dso.StatusDate, dso.ChangedDate),
			@currDescription	= dso.StatusDescription
		from 
			ApiDeliveryServiceOrders dso
		where 
			dso.OuterId		= @OuterId and 
			dso.AccountId	= @AccountId


		-- Р•СЃР»Рё СЃС‚Р°С‚СѓСЃ РёР·РјРµРЅРёР»СЃСЏ
		if @LastStatusId <> @currStatus
		begin

			-- РћР±РЅРѕРІР»СЏРµРј С‚РµРєСѓС‰РёР№ СЃС‚Р°С‚СѓСЃ Р·Р°РєР°Р·Р°
			update dso set
				StatusId			= @LastStatusId, 
				StatusDate			= @LastStatusDate,
				StatusDescription	= @StatusDescription,
				ChangedDate			= getdate()
			from  
				ApiDeliveryServiceOrders dso 
			where  
				dso.InnerId = @innerId


			-- РђСЂС…РёРІРёСЂСѓРµРј С‚РµРєСѓС‰РёР№ СЃС‚Р°С‚СѓСЃ РїРѕ РўРљ Рё РїСЂРѕРјРµР¶СѓС‚РѕС‡РЅС‹Рµ РїСЂРёС€РµРґС€РёРµ Р·РЅР°С‡РёРјС‹Рµ СЃС‚Р°С‚СѓСЃС‹ 
			insert ApiDeliveryServiceOrderStatusesHistory 
				(InnerId, StatusId, StatusDate, StatusDescription)
				select
					@innerId, @currStatus, @currStatusDate, @currDescription
			union
				select
					@innerId, s.StatusId, isnull(s.StatusDate, @currStatusDate), s.[Description]
				from
					#ordersStatuses s
					left join ApiDeliveryServiceOrderStatusesHistory sh ON sh.InnerId = @innerId AND s.StatusId = sh.StatusId AND s.StatusDate = sh.StatusDate	
				where
					sh.Id is null
				

			-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ ShopBaseUser
			declare 
				@authorId uniqueidentifier = '310FAFF6-9306-44EA-AEA5-44E43C0D5F39' --'4966E5F3-3A47-433D-872C-E525BE1DC096' ShopBaseBot

			-- Р”РѕР±Р°РІР»СЏРµРј Р·Р°РїРёСЃРё РІ РѕС‡РµСЂРµРґСЊ РЅР° РѕР±СЂР°Р±РѕС‚РєСѓ
			insert ActionsProcessingQueue 
				(ObjectId, ObjectTypeId, OperationId, ActionObject, PriorityLevel, AuthorId)
			select 
				cast(@innerId as varchar(36)), 901, 2,
				'{"OrderId":"' + cast(@innerId as varchar(36)) + '","TKStatusId":' + cast(@LastStatusId as varchar(4)) + '}', 
				2, @authorId

		end else begin

			-- РћР±РЅРѕРІР»СЏРµРј СЃС‚Р°С‚СѓСЃ
			update dso set
				StatusId			= @LastStatusId, 
				StatusDate			= @LastStatusDate,
				StatusDescription	= @StatusDescription,
				ChangedDate			= getdate()
			from  
				ApiDeliveryServiceOrders dso 
			where  
				dso.InnerId = @innerId

		end
	
		return 0

	end try
	begin catch
		set @ErrorMes = error_message()
		return 1
	end catch

end
