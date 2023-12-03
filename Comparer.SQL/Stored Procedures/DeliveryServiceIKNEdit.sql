create proc DeliveryServiceIKNEdit (
	@Id		int,			-- Идентификатор ИКН
	@Name	nvarchar(50)	-- Значение ИКН
) as
begin

	begin try

		update ApiDeliveryServicesIKNs
		set Name = @Name
		where Id = @Id

		return 0
	end try
	begin catch
		return 1
	end catch

end
