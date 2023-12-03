create proc DiscountsGroupChangeValidityPeriod
(
	@GroupId		int,					--идентифкатор группы 
	@DateFrom		datetime,
	@DateTo			datetime,
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
			 
			update DISCOUNTS
			set 
				DATEFROM = @DateFrom,
				DATETO = @DateTo
			from DISCOUNTS	d
				join DiscountsGroupsLinks l on l.DiscountId= d.ID and l.GroupId  = @GroupId

			-- Обновляем периоды
			update DiscountGroups
			set 
				MinDateFrom = @DateFrom,
				MaxDateTo = @DateTo
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
