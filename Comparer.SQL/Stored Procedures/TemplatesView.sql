create proc TemplatesView(@TypeId int) as
begin

	if @TypeId is null
		select A.Id, A.TypeId, A.Theme, A.Name, A.Body, A.OperationDate, A.AuthorId, B.NAME as AuthorName
		from Templates A
			join USERS B on B.ID=A.AuthorId
	else
		select A.Id, A.TypeId, A.Theme, A.Name, A.Body, A.OperationDate, A.AuthorId, B.NAME as AuthorName
		from Templates A
			join USERS B on B.ID=A.AuthorId
		where A.TypeId=@TypeId

end
