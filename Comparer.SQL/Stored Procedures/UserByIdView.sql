create proc UserByIdView (
	@Id		uniqueidentifier
) as
begin

	-- Основная информация
	select a.ID, a.NAME, a.USERSGROUP, a.FirstName, a.Patronymic, a.LastName, a.Email, a.Status, s.Name as 'StatusName',
		a.DepartmentId,
		a.RoleId,
		isnull(d.Name,'?') as 'DepartmentName',
		isnull(r.Name,'?') as 'RoleName'
	from USERS a
		join UserStatuses s on a.Status=s.Id
		left join Departments d on d.Id = A.DepartmentId
		left join Roles r on r.Id = A.RoleId
    where a.ID = @Id
	order by a.NAME

	-- Коды прав доступа
	select b.CODE
	from USERACCESSGROUPS b
		join USERACCESSGROUPSLINKS c on c.USERID = @Id 
	where c.ACCESSGROUPID = b.ID

end
