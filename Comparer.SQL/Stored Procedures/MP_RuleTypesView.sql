create proc MP_RuleTypesView
(
	@Code			varchar(50),	-- Код типа правила
	@ObjectTypeId	int				-- Идентификатор типа объекта
) as
begin
	
	select 
		-- Тип правила
		rt.Id					as 'Id', 
		rt.Name					as 'Name', 
		rt.Code					as 'Code',
		rt.ObjectTypeId			as 'ObjectId',
		rt.Description			as 'Description',
		ot.Name					as 'ObjectName'
	from SiteProductsRuleTypes rt
		join SiteProductsRuleObjectTypes ot on ot.Id = rt.ObjectTypeId
	where
		(@Code is null or (@Code is not null and rt.Code = @Code)) and
		(@ObjectTypeId is null or (@ObjectTypeId is not null and rt.ObjectTypeId = @ObjectTypeId))
	order by rt.ObjectTypeId, rt.Name

end
