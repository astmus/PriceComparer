create proc MP_RuleView
(
	@RuleId			int			-- Идентификатор правила
) as
begin
	
		-- Выгружаем общую информацию
		select 
			-- Правило
			r.Id					as 'Id', 		
			r.IsActive				as 'IsActive', 
			r.Caption				as 'Caption', 
			r.OrderNum				as 'OrderNum', 
			r.Args					as 'Args', 
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

		-- Список товаров
		select
			p.ID			as 'Id',
			p.SKU			as 'Sku',
			rtrim(p.NAME + ' ' + p.CHILDNAME) 
							as 'Name',
			m.NAME			as 'BrandName',
			p.PUBLISHED		as 'IsActive',
			l.Inversion		as 'Inversion'
		from SiteProductsRulesProductLinks l
			join Products p on p.ID = l.ProductId
			join MANUFACTURERS m on m.ID = p.MANID
		where 
			l.RuleId = @RuleId
		order by m.NAME, p.NAME, p.CHILDNAME
		
		-- Список брендов
		select
			m.ID			as 'Id',
			m.NAME			as 'Name',
			m.PUBLISHED		as 'IsActive',
			l.Inversion		as 'Inversion'
		from SiteProductsRulesBrandLinks l
			join MANUFACTURERS m on m.ID = l.BrandId
		where 
			l.RuleId = @RuleId
		order by m.NAME

		-- Список поставщиков
		select
			d.ID			as 'Id',
			d.NAME			as 'Name',
			d.ACTIVE		as 'IsActive',
			l.Inversion		as 'Inversion'
		from SiteProductsRulesDistributorLinks l
			join DISTRIBUTORS d on d.ID = l.DistributorId
		where 
			l.RuleId = @RuleId
		order by d.NAME

end
