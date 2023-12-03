create proc CompetitorFeedView
(
	@FeedId				int				-- Идентификатор фида	
) as
begin

	-- Информация о конкуренте
	select 
		c.Id			as 'Id',
		c.IsActive		as 'IsActive',
		c.Name			as 'Name',  
		c.OfficialName	as 'OfficialName',
		c.CreatedDate	as 'CreatedDate'
	from Competitors c
		join CompetitorsFeeds f on f.CompetitorId = c.Id
	where 
		f.Id = @FeedId

	-- Информация о фиде	
	select 
		f.Id				as 'Id',	 
		f.IsActive			as 'IsActive',
		f.Name				as 'Name',
		f.LastLoadDate		as 'LastLoadDate',
		f.ChangedDate		as 'ChangedDate',
		f.CreatedDate		as 'CreatedDate'
	from 
		CompetitorsFeeds f		
	where 
		f.Id = @FeedId

end
