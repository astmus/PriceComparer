create proc DeliveryServiceAccountSSDUpdate 
(
	@Id					int,				-- Идентификатор аккаунта
	@StatusSyncDate		datetime			-- Дата последней синхронизации статусов
) as
begin

	update 
		ApiDeliveryServicesAccounts
	set 
		StatusSyncDate = @StatusSyncDate
	where 
		Id = @Id

end
