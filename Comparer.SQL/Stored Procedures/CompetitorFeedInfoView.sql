create proc CompetitorFeedInfoView 
(
	@Id			int			-- ИД конкурента
) as
begin
	
	select 
		Id				as 'Id',
		IsActive		as 'IsActive',	
		Name			as 'Name',	
		OfficialName	as 'OfficialName',
		CreatedDate		as 'CreatedDate',
		ChangedDate		as 'ChangedDate'
	from
		Competitors 
	where
		Id = @Id

	select 
		f.Id			as 'Id',
		f.CompetitorId	as 'CompetitorId',
		f.Name			as 'Name',
		f.IsActive		as 'IsActive',
		f.LastLoadDate	as 'LastLoadDate',
		f.ChangedDate	as 'ChangedDate',
		f.CreatedDate	as 'CreatedDate'
   from 
		CompetitorsFeeds f
   where
		f.CompetitorId = @Id
   order by 
		f.Id

end
