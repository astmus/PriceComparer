create proc DeliveryServiceApiSettingsView (
	@Id		int		-- Идентификатор ТК
) as
begin

	if @Id is not null begin

		select
			i.Id as 'Id',
			isnull(i.Host,'') as 'Host',
			isnull(i.AuthUser,'') as 'AuthUser', 
			isnull(i.AuthPassword,'') as 'AuthPassword',
			isnull(i.Token,'') as 'Token', 
			isnull(i.DataFormatId,0) as 'DataFormatId'
		from ApiDeliveryServices d
			left join ApiDeliveryServicesSettings i on d.Id = i.ServiceId
		where d.Id = @Id AND i.IsActive = 1

	end else begin

		select
			i.Id as 'Id',
			isnull(i.Host,'') as 'Host',
			isnull(i.AuthUser,'') as 'AuthUser', 
			isnull(i.AuthPassword,'') as 'AuthPassword',
			isnull(i.Token,'') as 'Token', 
			isnull(i.DataFormatId,0) as 'DataFormatId'
		from ApiDeliveryServices d
			left join ApiDeliveryServicesSettings i on d.Id = i.ServiceId
		order by d.Id

	end

end
