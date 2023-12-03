create proc DeliveryServicesView (
	@Id		int		-- Идентификатор ТК
) as
begin

	select
		d.Id, d.Name, d.IsActive, d.IsMarketPlace
	from
		ApiDeliveryServices d
	where
		(@Id is null or (@Id is not null and d.Id = @Id ))

end
