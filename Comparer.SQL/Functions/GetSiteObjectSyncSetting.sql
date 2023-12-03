create function GetSiteObjectSyncSetting 
(
	@SiteId				uniqueidentifier,		-- Идентификатор сайта
	@ObjectTypeId		int,					-- Идентификатор типа объекта
	@SettingId			int						-- Идентификатор настройки
)
returns nvarchar(255)
as
begin
	
	if @SiteId is not null and @ObjectTypeId is not null and @SettingId is not null begin
		
		declare @SettingValue nvarchar(255)

		select @SettingValue = s.SettingValue
		from SiteObjectSyncSettings s
		where s.SiteId = @SiteId and s.ObjectTypeId = @ObjectTypeId and s.SettingId = @SettingId

		return @SettingValue

	end else begin

		return null

	end

	return ''
	
end
