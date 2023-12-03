CREATE PROC DeliveryServiceIKNsView (
	@AccountId	int = null,
	@ServiceId	int = null
) AS
BEGIN

	IF @AccountId Is Not NULL begin
		SELECT
			i.Id as 'Id',
			i.AccountId as 'AccountId',
			i.Name as 'Name'
		FROM
			ApiDeliveryServicesIKNs i
		WHERE
			i.AccountId = @AccountId
	end else
	IF @ServiceId Is Not NULL begin
		SELECT
			i.Id as 'Id',
			i.AccountId as 'AccountId',
			i.Name as 'Name'
		FROM
			ApiDeliveryServicesIKNs i
			JOIN ApiDeliveryServicesAccounts a ON i.AccountId = a.Id
		WHERE
			a.ServiceId = @ServiceId
	end else begin
		
		select
			i.Id as 'Id',
			i.AccountId as 'AccountId',
			i.Name as 'Name'
		from ApiDeliveryServicesIKNs i
		order by i.AccountId, i.Id

	end


END
