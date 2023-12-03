create proc BQOrdersIdHistoryView
(
	@Date		datetime		-- Дата выгрузки истории
)
as
begin
	
	select 
		c.ID as 'OrderId'
	from
		CLIENTORDERS c with (nolock)
	where 
		cast(c.DATE as date) = cast(@Date as date) and 
		--c.STATUS in (3, 5, 6, 16) and
		c.KIND in (1, 2) --and
		--c.SITEID <> '14F7D905-31CB-469A-91AC-0E04BC8F7AF3'
	order by
		c.ID

end
