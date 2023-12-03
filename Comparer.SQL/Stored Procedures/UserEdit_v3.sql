create proc UserEdit_v3 (
	@UserId			uniqueidentifier,
	@Name			varchar(255),
	@UserGroupId	tinyint,   
	@Password		nvarchar(255)		= null,
	@FirstName		nvarchar(25)		= null, 
	@Patronymic		nvarchar(25)		= null, 
	@LastName		nvarchar(25)		= null,
	@Email			nvarchar(100)		= null,
	@Status         int,
	@DepartmentId	int,
	@RoleId			int
) as
begin

	set nocount on

	declare @trancount int			-- Кол-во открытых транзакций
	select @trancount = @@TRANCOUNT

	-- старое имя
	declare @oldName varchar(255)
	select @oldName = Name from Users
	where ID = @UserId

	-- Обновление таблицы USERS
	begin try 

		-- Открыли транзакцию, если еще не открыта
		if @trancount = 0
			begin transaction

		if not exists (select 1 from USERS where ID=@UserID)
		begin
			insert USERS (ID, NAME, USERSGROUP, Password, FirstName, Patronymic, LastName, Email,Status, DepartmentId, RoleId)
			values (@UserId, @Name, @UserGroupId, @Password, @FirstName, @Patronymic, @LastName, @Email, @Status, @DepartmentId, @RoleId)
		end
		else
		begin 
			update USERS
			set 
				USERSGROUP		= @UserGroupId,
				Name			= @Name,
				FirstName		= @FirstName,
				Patronymic		= @Patronymic,
				LastName		= @LastName,
				Email			= @Email,
				Status			= @Status,
				DepartmentId	= @DepartmentId,
				RoleId			= @RoleId
			where ID = @UserId --and NAME=@Name

			-- Если изменен пароль
			if @Password is not null and @Password <> '' begin

				update USERS set Password = @Password where ID = @UserId

			end

		end
			
		-- Обновление таблицы USERACCESSGROUPLINKS
		delete USERACCESSGROUPSLINKS
		where  USERID=@UserId

		insert USERACCESSGROUPSLINKS (USERID, ACCESSGROUPID)
		select @UserId, b.ID
		from USERACCESSGROUPS b
			join #Access a on a.Code = b.CODE

		-- Обновляем имя пользователя в истории статусов заказов
		if(@oldName != @Name)
		begin
			update ORDERSSTATUSHISTORY
			set AUTHOR = @Name
			where AUTHOR = @oldName
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
