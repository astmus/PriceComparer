create proc TemplateEdit(
	@mode int, 
	@Id int, 
	@TypeId int, 
	@Name nvarchar(255), 
	@Theme nvarchar(255),
	@Body nvarchar(4000), 
	@AuthorId uniqueidentifier, 
	@newId int out
) as
begin

	set nocount on

	declare @trancount int
	select @trancount = @@TRANCOUNT
	if @trancount = 0
		begin transaction

	begin try 
		if @mode=1
		begin
			insert Templates (TypeId, Name, Theme, Body, AuthorId)
			values (@TypeId, @Name, @Theme, @Body, @AuthorId)
			
			select @newId = @@identity
		end
	
		if @mode=2
		begin
			update Templates
			set Name=@Name, Body=@Body, Theme=@Theme, OperationDate=getdate(), AuthorId=@AuthorId
			from Templates
			where Id=@Id
		end
	
		if @mode=3
		begin
			delete Templates
			from Templates
			where Id=@Id
		end
		
		if @trancount = 0
			commit transaction
		return 0
	end try 
	begin catch 
		if @trancount = 0
			rollback transaction
		return 1
	end catch 

end
