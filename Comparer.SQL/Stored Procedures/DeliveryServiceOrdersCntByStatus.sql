create proc DeliveryServiceOrdersCntByStatus 
(
	@ServiceId		int,			-- Идентификатор ТК
	@DateFrom		datetime,		-- 
	@DateTo			datetime		-- 
) as
begin

	declare @cnt table(
		StatusId	int,
		Cnt			int
	)

	insert into @cnt
		select StatusId, count(*) as 'Cnt'
		from ApiDeliveryServiceOrders
		where
			ServiceId = @ServiceId
			and CreatedDate >= @DateFrom 
			and CreatedDate <= @DateTo --cast(cast(dateadd(dd,1,@DateTo) as date) as datetime)
		group by ServiceId, StatusId

	select
		cnt.StatusId, st.Name, cnt.Cnt
	from
		@cnt cnt
		join ApiDeliveryServiceOrderStatuses st on cnt.StatusId = st.Id
	order by
		StatusId

end
