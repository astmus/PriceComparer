create proc ApiDsOrdersForStatusUpdate_v2 
(
	@ModeId			int,		-- Идентификатор режима
								-- 1 - Штатный (проверяем заказы, для которых с даты последнего изменения статуса прошло не более (включительно) @DaysCount)
								-- 2 - Не шатаный (проверяем заказы, для которых с даты последнего изменения статуса прошло более @DaysCount)
	@ServiceId		int,		-- Идентификатор ТК
	@AccountId		int,		-- Идентификатор аккаунта
	@DaysCount		int			-- Мин. кол-во дней, за которые не обновлялся статус
)
AS
begin

	declare 
		@calcDate date = cast(dateadd(day, -@DaysCount, getdate()) as date),
		@limitDate date = cast(dateadd(month, -2, getdate()) as date)

	-- print @calcDate

	-- Штатный
	if @ModeId = 1 begin

		select
			o.ID							as 'InnerId',
			iif(o.PUBLICNUMBER = '', cast(o.NUMBER as varchar(20)), o.PUBLICNUMBER)
											as 'PublicNumber', 
			o.DISPATCHNUMBER				as 'DispatchNumber',
			o.DELIVERYKIND					as 'DeliveryKindId',
			do.OuterId						as 'OuterId',
			do.ServiceId					as 'ServiceId',
			do.AccountId					as 'AccountId', 
			do.StatusId						as 'StatusId',
			do.StatusDate					as 'StatusDate',
			do.CreatedDate					as 'RegDate',
			isnull(oi.IKNId, 0)				as 'IknId',           
			isnull(ikns.Name, '')			as 'Ikn',           
			oi.LabelId						as 'LabelId',
			isnull(og.GroupId, '')			as 'GroupId',
			isnull(gi.IsSent, 0)			as 'GroupIsSent'
		from
			CLIENTORDERS o
			join ApiDeliveryServiceOrders do				on o.ID = do.InnerId	
			join ApiDeliveryServiceOrdersInfo oi			on oi.InnerId = do.InnerId
			left join ApiDeliveryServicesIKNs ikns			on oi.IKNId = ikns.Id
			left join ApiDeliveryServiceGroupOrderLinks og  on do.InnerId = og.OrderId
			left join ApiDeliveryServiceGroupsInfo gi		on og.GroupId = gi.Id
		where
			o.[STATUS] Not in (5, 6, 16) and 
			do.ServiceId = @ServiceId and
			cast(do.CreatedDate as date) >= @calcDate 
			and
			(
				do.StatusDate is null 
				or 				
				(
					do.StatusDate is not null 
					and
					cast(do.StatusDate as date) >= @calcDate
				)
			)
			and
			(@AccountId is null or (@AccountId is not null and do.AccountId = @AccountId)) 
			and oi.DisabledForTracking = 0
		order by
			do.CreatedDate

	end else
	-- Нештатный
	if @ModeId = 2 begin

		-- 3000 ограничение Почты России
		select top 3000
			o.ID							as 'InnerId',
			iif(o.PUBLICNUMBER = '', cast(o.NUMBER as varchar(20)), o.PUBLICNUMBER)
											as 'PublicNumber', 
			o.DISPATCHNUMBER				as 'DispatchNumber',
			o.DELIVERYKIND					as 'DeliveryKindId',
			do.OuterId						as 'OuterId',
			do.ServiceId					as 'ServiceId',
			do.AccountId					as 'AccountId', 
			do.StatusId						as 'StatusId',
			do.StatusDate					as 'StatusDate',
			do.CreatedDate					as 'RegDate',
			isnull(oi.IKNId, 0)				as 'IknId',           
			isnull(ikns.Name, '')			as 'Ikn',           
			oi.LabelId						as 'LabelId',
			isnull(og.GroupId, '')			as 'GroupId',
			isnull(gi.IsSent, 0)			as 'GroupIsSent'
		from
			CLIENTORDERS o
			join ApiDeliveryServiceOrders do				on o.ID = do.InnerId	
			join ApiDeliveryServiceOrdersInfo oi			on oi.InnerId = do.InnerId
			left join ApiDeliveryServicesIKNs ikns			on oi.IKNId = ikns.Id
			left join ApiDeliveryServiceGroupOrderLinks og  on do.InnerId = og.OrderId
			left join ApiDeliveryServiceGroupsInfo gi		on og.GroupId = gi.Id
		where
			o.[STATUS] Not in (5, 6, 16) and 
			(
				(
					do.StatusDate is null 
					and
					cast(do.CreatedDate as date) < @calcDate 
					and
					cast(do.CreatedDate as date) >= @limitDate
				)
				or
				(
					do.StatusDate is not null
					and
					cast(do.StatusDate as date) < @calcDate 
					and
					cast(do.StatusDate as date) >= @limitDate
				)
			)
			and
			(@AccountId is null or (@AccountId is not null and do.AccountId = @AccountId)) 
			and oi.DisabledForTracking = 0
		order by
			do.CreatedDate

	end

end
