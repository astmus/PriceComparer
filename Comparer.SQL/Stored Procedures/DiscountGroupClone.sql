create proc DiscountGroupClone
(
	@GroupName		nvarchar(100),			--  Название новой группы
	@GroupId		int,					--  Id клонируемой группы 
	@NewGroupId		int null output,		--  Id новой группы
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
	
			select @NewGroupId = Id from DiscountGroups where Name = @GroupName
	
			create TABLE #tmp_Discounts
			(
				Id			int					not null,	  					
				primary key	(Id)
			)
			insert DISCOUNTS
				([NAME]
			   ,[DESCRIPTION]
			   ,[SITEID]
			   ,[DATEFROM]
			   ,[DATETO]
			   ,[DISCOUNTTYPE]
			   ,[PRIORITY]
			   ,[DATECREATE]
			   ,[ACTIVE]
			   ,[ACTIONS]
			   ,[CONDITIONS]
			   ,[DONOTSUM]
			   ,[USEORIGINALPRICE]
			   ,[STOPONMATCH]
			   ,[DISCOUNTKIND]
			   ,[PUBLICGUID]
			   ,[AFFECTEDPRODUCTS]
			   ,[NAMEFORCLIENTS]
			   ,[ISADDABLE]
			   ,[EXCLUDEDDISCOUNTGUIDS]
			   ,[MarketType]
			   ,[CorrectPriceByPurchaseDisabled])
			output Inserted.ID into #tmp_Discounts
			select d.[NAME] + ' ('+ convert(varchar(10), @NewGroupId) +')'
			   , d.[DESCRIPTION]
			   , d.[SITEID]
			   , d.[DATEFROM]
			   , d.[DATETO]
			   , d.[DISCOUNTTYPE]
			   , d.[PRIORITY]
			   , getdate()
			   , d.[ACTIVE]
			   , d.[ACTIONS]
			   , d.[CONDITIONS]
			   , d.[DONOTSUM]
			   , d.[USEORIGINALPRICE]
			   , d.[STOPONMATCH]
			   , d.[DISCOUNTKIND]
			   , NEWID()
			   , d.[AFFECTEDPRODUCTS]
			   , d.[NAMEFORCLIENTS]
			   , d.[ISADDABLE]
			   , d.[EXCLUDEDDISCOUNTGUIDS]
			   , d.[MarketType]
			   , d.[CorrectPriceByPurchaseDisabled]
			from DiscountsGroupsLinks l 
				join DISCOUNTS d on l.DiscountId = d.ID
			where l.GroupId = @GroupId

			if(exists(select 1 from #tmp_Discounts))
			begin
				exec DiscountsAddInGroup @NewGroupId, @ErrorMes out
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
