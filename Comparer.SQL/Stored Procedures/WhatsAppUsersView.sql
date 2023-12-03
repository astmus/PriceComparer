create proc WhatsAppUsersView
(	
	@ClientId		uniqueidentifier	= null,		-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ РєР»РёС‚РµРЅС‚Р°
	@PhoneNumber	varchar(20)			= null		-- РќРѕРјРµСЂ С‚РµР»РµС„РѕРЅР° РєР»РёРµРЅС‚Р°
) as
begin
    
	select 
		u.ClientId, u.PublicId, u.PhoneNumber, u.ChatStatusId, u.CreatedDate
	from 
		WhatsAppUsers u
	where
		(@ClientId is null or (@ClientId is not null and u.ClientId = @ClientId)) and
		(@PhoneNumber is null or (@PhoneNumber is not null and u.PhoneNumber = @PhoneNumber))
	order by
		u.CreatedDate

end
