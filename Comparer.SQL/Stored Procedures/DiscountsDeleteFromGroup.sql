create proc DiscountsDeleteFromGroup
(
	@GroupId		int,			--идентифкатор группы 
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
			 
			-- Удаляем скидки
			delete DiscountsGroupsLinks 
			from #tmp_Discounts t
				 join DiscountsGroupsLinks l on t.Id = l.DiscountId and l.GroupId = @GroupId
		
			-- определяем минимальный и максимальные даты
			declare @minDateFrom datetime,
					@maxDateTo datetime

			select @minDateFrom = min(d.DateFrom)
			from DiscountsGroupsLinks l
				join DISCOUNTS d on l.DiscountId= d.ID
			where l.GroupId = @GroupId
		
			select @maxDateTo = max(d.DateTo)
			from DiscountsGroupsLinks l
				join DISCOUNTS d on l.DiscountId= d.ID
			where l.GroupId = @GroupId and d.DATETO is not null

			-- Обновляем периоды
			update DiscountGroups
			set MinDateFrom = @minDateFrom
			from DiscountGroups 
			where Id = @GroupId

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
