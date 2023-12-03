create proc WhatsAppUserSave
(	
	@ClientId			uniqueidentifier,		-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ РєР»РёРµРЅС‚Р°
	@PublicId			varchar(64),			-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ РєР»РёРµРЅС‚Р° РІРѕ РІРЅРµС€РЅРµР№ СЃРёСЃС‚РµРјРµ
	@PhoneNumber		varchar(20),
	@ChatStatusId		int,					-- РЎС‚Р°С‚СѓСЃ С‡Р°С‚Р° СЃ РїРѕР»СЊР·РѕРІР°С‚РµР»РµРј
	@ErrorMes			nvarchar(4000) out		-- РЎРѕРѕР±С‰РµРЅРёРµ РѕР± РѕС€РёР±РєРµ
) as
begin
    
	set nocount on
	set @ErrorMes = ''

	begin try

		insert into WhatsAppUsers (ClientId, PublicId, PhoneNumber, ChatStatusId) 
		values (@ClientId, @PublicId, @PhoneNumber, @ChatStatusId)

		return 0

	end try
	begin catch	
		set @ErrorMes = error_message();
		return 1
	end catch

end
