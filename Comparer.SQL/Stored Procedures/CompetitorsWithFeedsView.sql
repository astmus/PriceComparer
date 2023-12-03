create proc CompetitorsWithFeedsView 
as
begin

	select 
		c.Id			as 'Id',
		c.IsActive		as 'IsActive',	
		c.Name			as 'Name',	
		c.OfficialName	as 'OfficialName'
	from  Competitors  c
	order by c.Id

	select 
		f.Id			as 'Id',
		f.CompetitorId	as 'CompetitorId',
		f.Name			as 'Name',
		f.IsActive		as 'IsActive',
		f.LastLoadDate	as 'LastLoadDate',
		f.ChangedDate	as 'ChangedDate',
		f.CreatedDate	as 'CreatedDate'
   from CompetitorsFeeds f
   order by f.CompetitorId


end
