create proc DiscountGroupCreate
(
	@GroupName	nvarchar(100),			--  
	@GroupId int null output,			--  
	@ErrorMes		nvarchar(4000) out		-- Сообщение об ошибке
) as
begin

	set nocount on
	set @ErrorMes = ''

	if (exists (select 1 from DiscountGroups where Name = @GroupName))
	begin
		set @ErrorMes = 'Группа с таким именем уже существует!'
		return 1
	end

	declare @trancount int
	select @trancount = @@trancount

	begin try
	
	if @trancount = 0
		begin transaction

			
			insert into DiscountGroups(Name)
			values (@GroupName)
	
			select @GroupId = Id from DiscountGroups where Name = @GroupName
	
			if(exists(select 1 from #tmp_Discounts))
			begin
				exec DiscountsAddInGroup @GroupId, @ErrorMes out
			end


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
