create proc DiscountsGroupsView
(
	@GroupId			int					= null, -- Идентификатор группы
	@GroupName			varchar(255)		= null,	-- Имя группы
	@MinDateFrom		date				= null, -- От по минимальной дате
	@MaxDateTo			date				= null, -- До по максимальной дате действия скидки в группе
	@IsActive			bit					= null, -- Активность группы
	@CreatedDateFrom	date				= null, -- От по дате создания
	@CreatedDateTo		date				= null  -- До по дате создания
) as
begin

	begin try

		if (@GroupId is not null)
		begin
		
		select 
			g.Id 							as 'Id',
			g.Name 							as 'Name',
			g.CreatedDate 					as 'CreatedDate',
			g.MinDateFrom 					as 'MinDateFrom',
			g.MaxDateTo 					as 'MaxDateTo',
			isnull(ag.DiscountsCount, 0)	as 'DiscountsCount',
			cast(iif(isnull(ag.ActiveCount, 0) > 0, 1, 0) as bit)	
											as 'IsActive'
		from DiscountGroups g
			left join  
			(
				select l.GroupId, count(1) as 'DiscountsCount', sum(convert(int, d.ACTIVE)) as 'ActiveCount'
				from DiscountsGroupsLinks l 
					join DISCOUNTS d on l.DiscountId = d.ID
				group by l.GroupId
			) ag on ag.GroupId = g.Id
		where g.[Id] = @GroupId
		ORDER BY g.CreatedDate DESC;

		end
		else if (@GroupName is not null)
		begin
		
		select 
			g.Id 							as 'Id',
			g.Name 							as 'Name',
			g.CreatedDate 					as 'CreatedDate',
			g.MinDateFrom 					as 'MinDateFrom',
			g.MaxDateTo 					as 'MaxDateTo',
			isnull(ag.DiscountsCount, 0)	as 'DiscountsCount',
			cast(iif(isnull(ag.ActiveCount, 0) > 0, 1, 0) as bit)	
											as 'IsActive'
		from DiscountGroups g
			left join  
			(
				select l.GroupId, count(1) as 'DiscountsCount', sum(convert(int, d.ACTIVE)) as 'ActiveCount'
				from DiscountsGroupsLinks l 
					join DISCOUNTS d on l.DiscountId = d.ID
				group by l.GroupId
			) ag on ag.GroupId = g.Id
		where g.[Name] like @GroupName + '%'
		ORDER BY g.CreatedDate DESC;

		end else 
		select 
			g.Id 							as 'Id',
			g.Name 							as 'Name',
			g.CreatedDate 					as 'CreatedDate',
			g.MinDateFrom 					as 'MinDateFrom',
			g.MaxDateTo 					as 'MaxDateTo',
			isnull(ag.DiscountsCount, 0)	as 'DiscountsCount',
			cast(iif(isnull(ag.ActiveCount, 0) > 0, 1, 0) as bit)	
											as 'IsActive'
		from DiscountGroups g
			left join 
			(
				select l.GroupId, count(1) as 'DiscountsCount', sum(convert(int,d.ACTIVE)) as 'ActiveCount'
				from DiscountsGroupsLinks l 
					join DISCOUNTS d on l.DiscountId = d.ID
				group by l.GroupId
			) ag on ag.GroupId = g.Id
		where
			(@MinDateFrom is null or (@MinDateFrom is not null and @MinDateFrom <=  cast(g.MinDateFrom as date) )) and
			(@MaxDateTo is null or (@MaxDateTo is not null and @MaxDateTo >=  cast(g.MaxDateTo as date) )) and
			(@IsActive is null or (@IsActive is not null and @IsActive = iif(ag.ActiveCount > 0, 1, 0))) and
			(@CreatedDateFrom is null or (@CreatedDateFrom is not null and @CreatedDateFrom <=  cast(g.CreatedDate as date) )) and
			(@CreatedDateTo is null or (@CreatedDateTo is not null and @CreatedDateTo >=  cast(g.CreatedDate as date) )) 
		ORDER BY g.CreatedDate DESC;
	
	
	end try
	begin catch
		return 1
	end catch

end
