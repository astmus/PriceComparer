create proc UserSessionClear
(
	@UserId  uniqueidentifier,  -- ИД пользователя	 
	@SessionId			int		-- Идентификатор сессии
) as
begin

	begin try

		delete UserSession
	    where (@UserId is null or (@UserId is not null and UserId=@UserId ))
		and  (@SessionId is null or (@SessionId is not null and SessionId=@SessionId))

		return 0
	end try
	begin catch
		return 1
	end catch

end
