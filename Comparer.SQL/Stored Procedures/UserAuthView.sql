create proc UserAuthView (
	@Login			nvarchar(50),		-- Логин
	@Password		nvarchar(1000),		-- Пароль
	@AuthStatus		int	out				-- Статус авторизации
) as
begin

	begin try

	-- Стату не определен
	set @AuthStatus = 0

	declare @user table (
		Id		uniqueidentifier	not null,
		primary key(Id)
	)

	insert @user (Id)
	select ID from USERS where lower(NAME) = lower(@Login) and Password = @Password

	if exists (select 1 from @user) begin

		if (select count(1) from @user) > 1 begin

			-- Найден дубль пользователя
			select cast('00000000-0000-0000-0000-000000000000' as uniqueidentifier) as 'UserId'
			set @AuthStatus = 3
			return 0 

		end

		-- Успешная авторизация
		select	u.ID as 'UserId'from USERS u join @user e on e.Id = u.ID
		set @AuthStatus = 1
		return 0

	end else begin

		-- Пользователь не зарегистрирован в системе или пароль не верный
		select cast('00000000-0000-0000-0000-000000000000' as uniqueidentifier) as 'UserId'
		set @AuthStatus = 2
		return 0

	end

	end try
	begin catch
		select cast('00000000-0000-0000-0000-000000000000' as uniqueidentifier) as 'UserId'
		set @AuthStatus = 0
		return 1
	end catch
	
end
