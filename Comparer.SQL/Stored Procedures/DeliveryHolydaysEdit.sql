create proc DeliveryHolydaysEdit
(
	@Mode	bit = 0 --Режим (0 - сохранение, 1 - удаление)
) as
begin
	if(@Mode = 0)
	begin
		insert DeliveryHolydays (Date)
		select h.Date
			from #holidays h 
			left join DeliveryHolydays dh on dh.Date = h.Date
			where dh.Date is null
	end
	else
	begin
		delete dh
		from #holidays h
			left join DeliveryHolydays dh on dh.Date = h.Date
		where 
			dh.Date is not null
			
	end
end
