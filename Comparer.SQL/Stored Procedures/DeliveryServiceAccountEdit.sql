create proc DeliveryServiceAccountEdit (
	@Id				int,			-- Идентификатор ЛК	
	@Name			nvarchar(255),	-- Наименование аккаунта
    @Host			nvarchar(255),	-- Хост
	@AuthUser		nvarchar(100),	-- Логин
	@AuthPassword	nvarchar(100),	-- Пароль
	@AuthType		int,			-- Тип авторизации		
	@IsDefault		bit				-- Аккаунт по умолчанию                
) as
begin

	begin try

		update ApiDeliveryServicesAccounts
		set Name = @Name,
			Host = @Host,
			AuthUser = @AuthUser,
			AuthPassword = @AuthPassword,
			AuthType = @AuthType,		
			IsDefault = @IsDefault
		where Id = @Id

		return 0
	end try
	begin catch
		return 1
	end catch

end
