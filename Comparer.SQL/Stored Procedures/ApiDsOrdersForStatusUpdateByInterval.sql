create proc ApiDsOrdersForStatusUpdateByInterval
(
	@ServiceId		int,		-- Идентификатор ТК
	@AccountId		int,		-- Идентификатор аккаунта
	@DateFrom		datetime,
	@DateTo			datetime
)
AS
begin
    
	declare @now datetime = getdate()

	if (@DateFrom is null)
		set @DateFrom = dateadd(yy, -1, getdate())

	if (@DateTo is null)
		set @DateTo = dateadd(mm, -1, getdate())

	
	select
			o.ID							as 'InnerId',
			iif(o.PUBLICNUMBER = '', cast(o.NUMBER as varchar(20)), o.PUBLICNUMBER)
											as 'PublicNumber', 
			o.DISPATCHNUMBER				as 'DispatchNumber',
			do.OuterId						as 'OuterId',
			do.ServiceId					as 'ServiceId',
			do.AccountId					as 'AccountId', 
			do.StatusId						as 'StatusId',
			do.StatusDate					as 'StatusDate',
			do.CreatedDate					as 'RegDate',
			isnull(oi.IKNId, 0)				as 'IknId',           
			isnull(ikns.Name, '')			as 'Ikn',           
			oi.LabelId						as 'LabelId'
		from
			CLIENTORDERS o
			join ApiDeliveryServiceOrders do				on o.ID = do.InnerId	
			join ApiDeliveryServiceOrdersInfo oi			on oi.InnerId = do.InnerId
			left join ApiDeliveryServicesIKNs ikns			on oi.IKNId = ikns.Id
		where
			o.[STATUS] Not in (5, 6, 16) and 
			(@ServiceId is null or (@ServiceId is not null and do.ServiceId = @ServiceId)) and
			do.CreatedDate >= @DateFrom  and
			do.CreatedDate <= @DateTo  and
			(@AccountId is null or (@AccountId is not null and do.AccountId = @AccountId)) and
			oi.DisabledForTracking = 0
		order by
			do.CreatedDate

end
