create proc WhatsAppMessageSave
(	
	@OrderId			uniqueidentifier,		-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ Р·Р°РєР°Р·Р°
	@MessageStateId		int,					-- РЎС‚Р°С‚СѓСЃ СЃРѕРѕР±С‰РµРЅРёСЏ
												-- 1 - РЈСЃРїРµС€РЅРѕ РѕС‚РїСЂР°РІР»РµРЅРѕ
												-- 2 - РћС€РёР±РєР° РѕС‚РїСЂР°РІРєРё
	@ErrorMes			nvarchar(4000) out		-- РЎРѕРѕР±С‰РµРЅРёРµ РѕР± РѕС€РёР±РєРµ
) as
begin
    
	set nocount on
	set @ErrorMes = ''

	begin try

		insert WhatsAppMessages (OrderId, MessageStateId) 
		values (@OrderId, @MessageStateId)

		return 0

	end try
	begin catch	
		set @ErrorMes = error_message();
		return 1
	end catch

end
