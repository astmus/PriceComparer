create proc CompetitorView 
(
	@Id			int			-- ИД
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

end
