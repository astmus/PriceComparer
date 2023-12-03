create proc DeliveryServiceIKNDelete (
	@Id		int		-- Идентификатор ИКН
) as
begin

	begin try

		delete ApiDeliveryServicesIKNs where Id = @Id

		return 0
	end try
	begin catch
		return 1
	end catch

end
