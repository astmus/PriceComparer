create proc TKOrderDisabledForTrackingEdit
(
	@DisabledForTracking bit,
	@ErrorMes	nvarchar(4000) out
)
as
begin

	set nocount on
	set @ErrorMes = ''
		
	begin try

		update oi
		set 
			oi.DisabledForTracking = @DisabledForTracking
		from #Ids i
		 join ApiDeliveryServiceOrdersInfo oi on oi.InnerId = i.Id
	
		return 0

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
