create proc DeliveryServiceApiSettingsEdit (
	@Id				int,				-- Идентификатор ТК
	@Host			varchar(255),		-- Базовый хост Api 
	@AuthUser		varchar(255),		-- Логин
	@AuthPassword	varchar(255),		-- Пароль
	@Token			varchar(50),		-- Токен
	@DataFormatId	int					-- Идентификатор формата данных
) as
begin

	begin try

		update ApiDeliveryServicesSettings
		set Host			= isnull(@Host,Host),
			AuthUser		= isnull(@AuthUser,AuthUser), 
			AuthPassword	= isnull(@AuthPassword,AuthPassword),
			Token			= isnull(@Token,Token),
			DataFormatId	= isnull(@DataFormatId,DataFormatId)
		where Id = @Id

		return 0
	end try
	begin catch
		return 1
	end catch

end
