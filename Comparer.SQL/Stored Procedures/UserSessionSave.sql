create proc UserSessionSave
(
	@UserId  uniqueidentifier,  -- ИД пользователя	 
	@SessionId			int		-- Идентификатор сессии
) as
begin

	begin try

		declare	@Date		datetime	  
		set @Date = getdate()


		if ( not exists (select Id from  UserSession where UserId = @UserId))
		begin
			
			insert UserSession (UserId,	SessionId, DateSession)
			values (@UserId, @SessionId, @Date)

		end
		else 
		begin
			update 
				UserSession
			set 
				SessionId = @SessionId, 
				DateSession = @Date
			where
				UserId=@UserId

		end

		return 0
	end try
	begin catch
		return 1
	end catch

end
