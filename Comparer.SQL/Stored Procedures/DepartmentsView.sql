create proc DepartmentsView
(
	@Id			int		= null	
) as
begin
		
	if @Id is not null 

		select 
			d.Id			as 'Id',
			d.Name			as 'Name',
			d.ShortName		as 'ShortName'
		from Departments d		
		where d.Id = @Id
			
	else

		select 
			d.Id			as 'Id',
			d.Name			as 'Name',
			d.ShortName		as 'ShortName'
		from Departments d
		order by d.Name

end
