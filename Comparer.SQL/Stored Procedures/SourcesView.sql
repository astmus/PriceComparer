create proc SourcesView
as
begin
	select 
		Id,
		Name
	from Sources
end

-- exec SourcesView
