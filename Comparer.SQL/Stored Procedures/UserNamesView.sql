--Выводит список пользователей
create proc [dbo].[UserNamesView] (	@Group tinyint) as --идентификатор группы
begin

	if @Group is null
	begin
		select A.ID, A.NAME as UserName, A.USERSGROUP
		from USERS A
		join USERGROUPS B on B.ID=A.USERSGROUP
		where A.Status=1
		order by A.NAME
	end
	else 
	begin
		select A.ID, A.NAME as UserName, A.USERSGROUP
		from USERS A
		join USERGROUPS B on B.ID=A.USERSGROUP
		where A.USERSGROUP=@Group and  A.Status=1
		order by A.NAME
	end
	
end
