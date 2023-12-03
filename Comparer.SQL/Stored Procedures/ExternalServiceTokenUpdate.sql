create proc ExternalServiceTokenUpdate (
	@ServiceId				int,		-- Идентификатор сервиса
	@Token          nvarchar(max),		-- Идентификатор сиссии	
	@TokenExpiry	datetime			-- Время жизни идентификатора сессии
) as
begin

	begin try

		declare @now datetime = getdate()
		
		update ExternalServicesAccounts	set
			Token = @Token,
			TokenExpiry = isnull(@TokenExpiry, dateadd(mi, isnull(TokenLifeTime, 60), @now))
			from ExternalServicesAccounts
		where ServiceId = @ServiceId

		return 0

	end try
	begin catch
		return 1
	end catch
	
end
