create proc HolidaysEdit
(
	@Mode	bit = 0 --Режим (0 - сохранение, 1 - удаление)
) as
begin
	if(@Mode = 0)
	begin
		insert Holidays(Date)
		select th.Date
			from #holidays th 
			left join Holidays t on th.Date = t.Date
			where t.Date is null
	end
	else
	begin
		delete Holidays
		where Date in 
			(select th.Date
			from #holidays th
			left join Holidays t on th.Date = t.Date
			where t.Date is not null)
	end
end
