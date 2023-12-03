create proc UserPasswordsEdit
(
	@UserId	uniqueidentifier,				-- Id пользователя
	@HashedPassword	nvarchar(255),			-- хэшированный пароль
	@ErrorMes	nvarchar(4000) out
)
as
begin

	set nocount on
	set @ErrorMes = ''
		
	begin try

	if (exists (select 1 from UserPasswords where UserId = @UserId))
		begin
			update UserPasswords
			set HashedPassword = @HashedPassword
			where UserId = @UserId
		end
	else
		begin
			insert UserPasswords (UserId, HashedPassword)
			values (@UserId, @HashedPassword)
		end
	
		return 0

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
