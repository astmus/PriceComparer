create proc UsersView_v2 (
	@Group		tinyint			=null,
	@Status		int	   		    =null,
	@Name		varchar(255)	=null,
	@Email		varchar(255)	=null
) as
begin
		select A.ID, A.NAME,
		 concat(LTRIM(A.FirstName),' ', LTRIM(A.Patronymic),' ', LTRIM(A.LastName)) as FIO, 
		 A.USERSGROUP, A.Email, A.Status, s.Name as 'StatusName'
		from USERS A
		join UserStatuses s on A.Status=s.Id
	    where A.USERSGROUP=isnull(@Group, A.USERSGROUP) and 
			  A.Status=isnull(@Status, A.Status) and 
			  A.NAME LIKE '%' + isnull(@Name, A.NAME) + '%' and
			 (A.Email LIKE '%' +isnull(@Email, A.Email)+ '%'  or  isnull(@Email,'1')='1' or @Email='')
		order by A.NAME
end
