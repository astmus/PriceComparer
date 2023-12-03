create proc MP_RuleItemsView
(
	@SiteId			uniqueidentifier,			-- Идентификатор заказа
	@RuleId			int,						-- Идентификатор правила
	@TypeId			int,						-- Идентификатор типа правила
	@ObjectTypeId	int,						-- Идентификатор типа объекта
	@IsActive		bit,						-- Активность
	@Caption		varchar(255)				-- Описание правила
) as
begin
	
	if @RuleId is not null begin

		select 
			-- Правило
			r.Id					as 'Id', 		
			r.IsActive				as 'IsActive', 
			r.Caption				as 'Caption', 
			r.OrderNum				as 'OrderNum', 
			r.CreatedDate			as 'CreatedDate', 
			r.ChangedDate			as 'ChangedDate',
			-- Тип правила
			rt.Id					as 'RuleTypeId', 
			rt.Name					as 'RuleTypeName', 
			rt.Code					as 'RuleTypeCode',
			rt.ObjectTypeId			as 'RuleTypeObjectTypeId',
			-- Сайт
			r.SiteId				as 'SiteId', 		
			s.NAME					as 'SiteName'
		
		from SiteProductsRules r
			join SiteProductsRuleTypes rt on r.RuleTypeId = rt.Id
			join SiteProductsRuleObjectTypes o on o.Id = rt.ObjectTypeId
			join SITES s on s.ID = r.SiteId
		where
			r.Id = @RuleId

	end else begin

		select 
			-- Правило
			r.Id					as 'Id', 		
			r.IsActive				as 'IsActive', 
			r.Caption				as 'Caption', 
			r.OrderNum				as 'OrderNum', 
			r.CreatedDate			as 'CreatedDate', 
			r.ChangedDate			as 'ChangedDate',
			-- Тип правила
			rt.Id					as 'RuleTypeId', 
			rt.Name					as 'RuleTypeName', 
			rt.Code					as 'RuleTypeCode',
			rt.ObjectTypeId			as 'RuleTypeObjectTypeId',
			-- Сайт
			r.SiteId				as 'SiteId', 		
			s.NAME					as 'SiteName'
		
		from SiteProductsRules r
			join SiteProductsRuleTypes rt on r.RuleTypeId = rt.Id
			join SiteProductsRuleObjectTypes o on o.Id = rt.ObjectTypeId
			join SITES s on s.ID = r.SiteId
		where
			(@SiteId		is null or (@SiteId			is not null and s.ID = @SiteId))						and		
			(@TypeId		is null or (@TypeId			is not null and r.RuleTypeId = @TypeId))				and
			(@ObjectTypeId	is null or (@ObjectTypeId	is not null and rt.ObjectTypeId = @ObjectTypeId))		and
			(@Caption		is null or (@Caption		is not null and r.Caption like '%' + @Caption + '%'))	and
			(@IsActive		is null or (@IsActive		is not null and r.IsActive = @IsActive))
		order by r.OrderNum

	end

end
