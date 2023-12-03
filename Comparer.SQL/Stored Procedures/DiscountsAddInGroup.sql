create proc DiscountsAddInGroup
(
	@GroupId	int,			--идентифкатор группы 
	@ErrorMes		nvarchar(4000) out		-- Сообщение об ошибке
) as
begin

	set nocount on
	set @ErrorMes = ''
	
	if (not exists (select 1 from DiscountGroups where Id = @GroupId))
	begin
		set @ErrorMes = 'Группа не найдена!'
		return 1
	end

	declare @trancount int
	select @trancount = @@trancount

	begin try
	
		if @trancount = 0
			begin transaction
	      
		
			-- определяем минимальный и максимальные даты
			declare @minDateFrom datetime,
					@maxDateTo datetime

			select @minDateFrom = min(d.DateFrom)
			from #tmp_Discounts t
				left join DiscountsGroupsLinks l on t.Id = l.DiscountId
				join DISCOUNTS d on t.Id = d.ID
			where l.GroupId is null 
		
			select @maxDateTo = max(d.DateTo)
			from #tmp_Discounts t
				left join DiscountsGroupsLinks l on t.Id = l.DiscountId
				join DISCOUNTS d on t.Id = d.ID
			where l.GroupId is null and d.DATETO is not null
			 
			-- Добавляем скидки
			insert DiscountsGroupsLinks 
			select @GroupId, t.Id
			from #tmp_Discounts t
				left join DiscountsGroupsLinks l on t.Id = l.DiscountId
				join DISCOUNTS d on t.Id = d.ID
			where l.GroupId is null 
			
			declare @curMinDateFrom datetime,
					@curMaxDateTo datetime
			select 
				@curMinDateFrom = MinDateFrom,
				@curMaxDateTo = MaxDateTo
			from DiscountGroups 
			where Id = @GroupId
			
			-- Обновляем периоды
			if(@curMinDateFrom is null or @minDateFrom < @curMinDateFrom)
				update DiscountGroups
				set MinDateFrom = @minDateFrom
				from DiscountGroups 
				where Id = @GroupId

			if(@curMaxDateTo is null or @maxDateTo > @curMaxDateTo)
				update DiscountGroups
				set MaxDateTo = @maxDateTo
				from DiscountGroups 
				where Id = @GroupId

		if @trancount = 0
			commit transaction
	end try
	begin catch
		if @trancount = 0
			rollback transaction
		set @ErrorMes = error_message()
		return 1
	end catch

end
