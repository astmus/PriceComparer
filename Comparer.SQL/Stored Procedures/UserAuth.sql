create proc UserAuth 
(
	@Login		varchar(64),
	@Password	varchar(255)
) as
begin

	declare
		@Id		uniqueidentifier	= null

	select 
		@Id = u.ID 
	from 
		Users u 
		join UserPasswords p on u.ID = p.UserId 
	where 
		u.Email = @Login and 
		p.HashedPassword = @Password
		
	if (@Id is null)
		return 0

	-- Основная информация
	select 
		u.ID, 
		u.NAME, 
		u.USERSGROUP, 
		u.Email,
		u.DepartmentId			as 'DepartmentId',
		isnull(d.Name, '')		as 'DepartmentName',
		u.RoleId				as 'RoleId',
		isnull(r.Name, '')		as 'RoleName',
		iif(isnull(r.TypeId, 0) = 2, cast(1 as bit), cast(0 as bit))
								as 'IsLeader'
	from USERS u
		join UserPasswords p on u.ID = p.UserId
		left join Departments d on d.Id = u.DepartmentId
		left join Roles r on r.Id = u.RoleId
    where 
		u.ID = @Id

	-- Коды прав доступа
	select 
		b.CODE
	from 
		USERACCESSGROUPS b
		join USERACCESSGROUPSLINKS c on c.ACCESSGROUPID = b.ID 
	where 
		c.USERID = @Id 

end
