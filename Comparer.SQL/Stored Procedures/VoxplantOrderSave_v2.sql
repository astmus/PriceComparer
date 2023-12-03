create proc VoxplantOrderSave_v2
(
	@OrderId		uniqueidentifier,	--	Идентификатор заказа
	@StatusId		int,				--  Идентификатор статуса
	@Scenario		int					--  Идентификатор сценария	
) as
begin

	begin try

		declare
			@OldScenarioId	int,  
			@OldStatusId	int, 
			@ChangeDate		datetime	  

		set @OldScenarioId	= null
		set @OldStatusId	= null
		set @ChangeDate		= getdate()

		select 
			@OldScenarioId	= ScenarioId,
			@OldStatusId	= StatusId
		from 
			VoximplantOrders
		where 
			OrderId = @OrderId

		if (@OldScenarioId is null and @OldStatusId is null)
		begin
			
			insert VoximplantOrders (OrderId, StatusId, ScenarioId, ChangedDate)
			values (@OrderId, @StatusId, @Scenario, @ChangeDate)

		end
		else 
		begin
			
			if @Scenario = 1 and (@OldScenarioId = 2 or @OldScenarioId = 1 or @OldScenarioId = 0) begin
			
				update 
					VoximplantOrders
				set 
					StatusId	= @StatusId,
					ScenarioId	= @Scenario,
					ChangedDate	= @ChangeDate
				where
					OrderId = @OrderId

			end

		end

		return 0
	end try
	begin catch
		return 1
	end catch

end
