create proc UserEdit (
	@UserId			uniqueidentifier,
	@Name			varchar(255),
	@UserGroupId	tinyint,   
	@Password		nvarchar(255)		= null,
	@FirstName		nvarchar(25)		= null, 
	@Patronymic		nvarchar(25)		= null, 
	@LastName		nvarchar(25)		= null,
	@Email			nvarchar(100)		= null
) as
begin

	set nocount on

	declare @trancount int			-- Кол-во открытых транзакций
	select @trancount = @@TRANCOUNT

	-- Обновление таблицы USERS
	begin try 

		-- Открыли транзакцию, если еще не открыта
		if @trancount = 0
			begin transaction

		if not exists(select count(1) from USERS where ID=@UserID)
		begin
			insert USERS (ID, NAME, USERSGROUP, Password, FirstName, Patronymic, LastName, Email)
			values (@UserId, @Name, @UserGroupId, @Password, @FirstName, @Patronymic, @LastName, @Email)
		end
		else
		begin 
			update USERS
			set 
				USERSGROUP	= @UserGroupId,
				FirstName	= @FirstName,
				Patronymic	= @Patronymic,
				LastName	= @LastName,
				Email		= @Email				
			where ID=@UserId --and NAME=@Name
		end
			
		-- Обновление таблицы USERACCESSGROUPLINKS
		delete USERACCESSGROUPSLINKS
		where  USERID=@UserId

		insert USERACCESSGROUPSLINKS (USERID, ACCESSGROUPID)
		select @UserId, b.ID
		from USERACCESSGROUPS b
			join #Access a on a.Code = b.CODE

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
