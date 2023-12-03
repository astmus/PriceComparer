create proc DiscountGroupSetActivity
(
	@GroupId		int,			--  идентификатор группы
	@Activity		bit,			-- Активность
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

	begin try
	
			update d
			set d.ACTIVE = @Activity
			from DiscountsGroupsLinks l
			join DISCOUNTS d on d.ID = l.DiscountId
			where GroupId = @GroupId
	end try
	begin catch
		set @ErrorMes = error_message()
		return 1
	end catch

end
