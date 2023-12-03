create proc RolesView
(
	@Id					int		= null,
	@DepartmentId		int		= null
) as
begin
		
	if @Id is not null 

		select 
			r.Id						as 'Id',
			r.Name						as 'Name',
			r.DepartmentId				as 'DepartmentId',
			r.TypeId					as 'TypeId',
			r.DefaultAccessGroups		as 'DefaultAccessGroups'
		from Roles r		
		where r.Id = @Id

	else if @DepartmentId is not null 

		select 
			r.Id						as 'Id',
			r.Name						as 'Name',
			r.DepartmentId				as 'DepartmentId',
			r.TypeId					as 'TypeId',
			r.DefaultAccessGroups		as 'DefaultAccessGroups'
		from Roles r		
		where r.DepartmentId = @DepartmentId
		order by r.Name

	else

		select 
			r.Id						as 'Id',
			r.Name						as 'Name',
			r.DepartmentId				as 'DepartmentId',
			r.TypeId					as 'TypeId',
			r.DefaultAccessGroups		as 'DefaultAccessGroups'
		from Roles r	
		order by r.DepartmentId, r.Name			

end
