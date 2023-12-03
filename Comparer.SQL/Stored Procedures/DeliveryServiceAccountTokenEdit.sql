create proc DeliveryServiceAccountTokenEdit (
	@Id				int,				-- Идентификатор ЛК	
	@Token          nvarchar(255),		-- Идентификатор сиссии	
	@TokenExpiry	datetime			-- Время жизни идентификатора сиссии
) as
begin

	begin try

		declare @now datetime = getdate()
		
		update ApiDeliveryServicesAccounts
		set Token = @Token,
			TokenExpiry = isnull(@TokenExpiry, dateadd(mi, isnull(TokenLifeTime,30), @now))
		where Id = @Id

		return 0
	end try
	begin catch
		return 1
	end catch

end
