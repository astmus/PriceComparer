create proc DeliveryServiceAccountSSDView 
(
	@Id			int				-- Идентификатор аккаунта
) as
begin

	select 
		StatusSyncDate 
	from 
		ApiDeliveryServicesAccounts
	where 
		Id = @Id

end
