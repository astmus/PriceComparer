create proc UsersBoundsView 
(
	@DepartmentId	int			= null
) as
begin

	select 
		u.ID as 'UserId',
		u.NAME as 'Name',
		concat(LTRIM(u.LastName),' ', LTRIM(u.FirstName),' ', LTRIM(u.Patronymic)) as 'FIO',
		r.Name as 'Role',
		r.TypeId as 'TypeId',
		ub.ParentId as 'ParentId'
			
	from USERS u
		join Roles r on u.RoleId = r.Id
		left join UsersBounds ub on u.ID = ub.UserId
	where
		u.DepartmentId = @DepartmentId and
		u.Status = 1
	order by 
		u.NAME

end
