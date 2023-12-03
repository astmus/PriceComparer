create proc DiscountsGroupView
(
	@GroupId	int			--идентифкатор группы 
) as
begin

	begin try

		if (not exists (select 1 from DiscountGroups where Id = @GroupId))
			return 1

		select 
			d.Id						as 'Id',
			d.NAME						as 'Name',
			d.DATEFROM					as 'DateFrom',
			d.DATETO					as 'DateTo',
			d.ACTIVE					as 'IsActive',
			d.DISCOUNTTYPE				as 'DiscountType',
			d.DISCOUNTKIND				as 'DiscountKind',
			d.PRIORITY					as 'Priority',
			d.SITEID					as 'SiteId',
			d.MarketType				as 'MarketType',
			d.CorrectPriceByPurchaseDisabled 
										as 'CorrectPriceByPurchaseDisabled',
			d.DESCRIPTION				as 'Discription'
		from DiscountsGroupsLinks l
		join DISCOUNTS d on l.DiscountId = d.ID
		where GroupId = @GroupId
		ORDER BY DATEFROM DESC;
	
	end try
	begin catch
		return 1
	end catch

end
