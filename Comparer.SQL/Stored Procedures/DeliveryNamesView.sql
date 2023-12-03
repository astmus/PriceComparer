create proc DeliveryNamesView (
	@OnlyActive		bit			-- Только активные
) as
begin
	
	if @OnlyActive = 1 begin

		select d.ID as 'Id', d.NAME as 'Name'
		from DELIVERYTYPES d 
		where d.IS_ACTIVE = 1 and d.DISABLED = 0 
		order by d.NAME

	end else begin

		select d.ID as 'Id', d.NAME as 'Name'
		from DELIVERYTYPES d 		
		order by d.NAME

	end
				
end
