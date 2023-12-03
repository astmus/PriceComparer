create proc TrackerProcessEdit
(
	@AccountId			int, 
	@StateId			int,
	@StartTrackingDate  datetime,
	@Errors				nvarchar(4000),
	@ErrorMes	 nvarchar(4000) out
)
as
begin

	set nocount on
	set @ErrorMes = ''
		
	begin try
		
		update ApiDeliveryServiceTrackers
		set 
			StateId = @StateId,
			StartTrackingDate = @StartTrackingDate,
			Errors = @Errors
		where 
			AccountId = @AccountId
	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end


/*

begin tran

   declare  
		@ErrorMes	 nvarchar(4000), @res int
   
   exec @res = TrackerProcessEdit 1, 1,'20220808 23:00:00', 'Тестовая ошибка!!!',  @ErrorMes out
   select  @res, @ErrorMes

   select * from ApiDeliveryServiceTrackers  

rollback tran
*/
