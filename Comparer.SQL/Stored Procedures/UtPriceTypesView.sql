create proc UtPriceTypesView 
as
begin
	
	select
		Id,
		OuterId,
		Name
	from
		UtPriceTypes
	order by
		Id

end
