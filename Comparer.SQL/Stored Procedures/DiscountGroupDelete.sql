create proc DiscountGroupDelete
(
	@GroupId		int,			--  
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

			delete DiscountsGroupsLinks
			where GroupId = @GroupId

			delete DiscountGroups
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
