create proc DeliveryServiceIKNCreate (
	@AccountId		int,			-- Идентификатор аккаунта
	@Name			nvarchar(50),	-- Значение ИКН
	@NewId			int	out			-- Идентификатор созданного ИКН
) as
begin

	set @NewId = 0;

	begin try

		insert ApiDeliveryServicesIKNs (AccountId, Name) values (@AccountId, @Name)
		set @NewId = @@identity

		return 0
	end try
	begin catch
		return 1
	end catch

end
