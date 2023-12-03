create proc CompetitorFeedMatchingStatView
(
	@FeedId			int			-- Идентификатор фида	
) as
begin
	
	declare
		@TotalCount				int = 0,
		@NotMatchedCount		int = 0,
		@UnusedCount			int = 0

	select 
		@TotalCount = count(1) 
	from 
		CompetitorsFeedItems 
	where 
		FeedId = @FeedId

	select 
		@NotMatchedCount = count(1) 
	from 
		CompetitorsFeedItems i 
		left join CompetitorsFeedProductLinks l on l.FeedItemId = i.Id 
	where 
		FeedId = @FeedId 
		and l.FeedItemId is null

	select 
		@UnusedCount = count(1) 
	from 
		CompetitorsFeedItems 
	where 
		FeedId = @FeedId
		and IsUsed = 0

	select 
		@TotalCount			as 'TotalCount',
		@NotMatchedCount	as 'NotMatchedCount',
		@UnusedCount		as 'UnusedCount'
		
end
