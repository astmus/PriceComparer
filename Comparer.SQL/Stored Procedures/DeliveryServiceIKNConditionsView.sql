CREATE PROC DeliveryServiceIKNConditionsView (
	@IKNId			int = null,			-- Идентификатор
	@AccountId		int = null			-- Идентификатор
) AS
BEGIN

	CREATE TABLE #tempIds
	(	
		Id	int	not null,				-- идентификатор 
		primary key(Id)
	)

	if @IKNId is Not Null begin

		INSERT INTO #tempIds
			SELECT Id FROM ApiDeliveryServicesIKNConditions WHERE IKNId = @IKNId

	end else
	if @AccountId is not null begin

		INSERT INTO #tempIds
			SELECT ik.Id
			FROM   ApiDeliveryServicesIKNs i
				   JOIN ApiDeliveryServicesIKNConditions ik on i.Id = ik.IKNId
			WHERE  i.AccountId = @AccountId
	
	end else begin

		INSERT INTO #tempIds
			SELECT ik.Id
			FROM   ApiDeliveryServicesIKNs i
				   JOIN ApiDeliveryServicesIKNConditions ik on i.Id = ik.IKNId
	end

	SELECT
		ik.Id, ik.IKNId, ik.Name, ik.Conditions, ik.OrderNum,
		ikn.Name as 'IKNName'
	FROM
		#tempIds t
		JOIN ApiDeliveryServicesIKNConditions ik ON t.Id = ik.Id
		JOIN ApiDeliveryServicesIKNs ikn ON ik.IKNId = ikn.Id

	--DROP TABLE #accIds

END
