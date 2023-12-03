create proc UsersBoundsKCView
as
begin
	
	select 
		s.ID								as 'SupervisorId', 
		s.LastName + ' ' + s.FirstName		as 'SupervisorFIO', 
		u.ID								as 'UserId'
	from
		UsersBounds b
		join USERS u on u.ID = b.UserId
		join USERS s on s.ID = b.ParentId
	where
		u.DepartmentId = 7
		and s.RoleId = 21
		and u.RoleId = 22
	order by
		u.LastName, u.FirstName

end
