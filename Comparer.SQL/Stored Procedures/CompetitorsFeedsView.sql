create proc CompetitorsFeedsView
(
	@CompetitorId		varchar(100),	-- Наименование
	@IsActive			bit				-- Активный
) as
begin
	
	select 
		Id,
		CompetitorId,
		IsActive,
		Name,
		LastLoadDate,
		ChangedDate,
		CreatedDate
	from
		CompetitorsFeeds 
	where
		CompetitorId = @CompetitorId
		and (@IsActive is Null OR (@IsActive is Not Null AND IsActive = @IsActive))

end
