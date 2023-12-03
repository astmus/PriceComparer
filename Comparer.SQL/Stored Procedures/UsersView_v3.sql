create proc UsersView_v3 (
	@Group		tinyint			= null,
	@Status		int	   		    = null,
	@Name		varchar(255)	= null,
	@Email		varchar(255)	= null,
	@DepartmentId	int			= null,
	@RoleId			int			= null
) as
begin

	if @Name = '' set @Name = null
	if @Email = '' set @Email = null

		select 
			A.ID, 
			A.NAME,
			concat(LTRIM(A.LastName), ' ', LTRIM(A.FirstName),' ', LTRIM(A.Patronymic)) as FIO,
			A.USERSGROUP, 
			isnull(A.Email,'') as 'Email', 
			isnull(A.Status,0) as 'Status', 
			isnull(s.Name,'') as 'StatusName',
			A.DepartmentId,
			A.RoleId,
			isnull(d.ShortName,'?') as 'DepartmentName',
			isnull(r.Name,'?') as 'RoleName'
		from USERS A
			join UserStatuses s on A.Status=s.Id
			left join Departments d on d.Id = A.DepartmentId
			left join Roles r on r.Id = A.RoleId
	    where
			(@Group is null or (@Group is not null and A.USERSGROUP = @Group)) and 
			(@Status is null or (@Status is not null and A.Status = @Status)) and 
			(@Name is null or (@Name is not null and A.NAME like '%' + @Name + '%')) and
			(@Email is null or (@Email is not null and A.Email like ('%' + @Email + '%'))) and
			(@DepartmentId is null or (@DepartmentId is not null and d.Id = @DepartmentId)) and
			(@RoleId is null or (@RoleId is not null and r.Id = @RoleId))
		order by 
			A.NAME
end
