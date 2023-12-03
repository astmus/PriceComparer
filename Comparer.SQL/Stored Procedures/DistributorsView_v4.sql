create proc DistributorsView_v4 
(
	@Name						varchar(255),
	@Email						nvarchar(255),
	@BrandId					uniqueidentifier,
	@Active						bit,
	@SendRequestMode			int,
	@GoInPurchaseList			bit,
	@GoInAutoControl			bit,
	@IsOfficialDealer			bit,
	@IsOfficialDealerForBrand	bit,
	@IsGulden					bit
) as
begin

	-- Если не нужны поставщики по бренду, то выведем вне зависимости от этого условия
	if (@IsOfficialDealerForBrand = 0) 
		set @IsOfficialDealerForBrand = null

	if (@IsOfficialDealer = 0) 
		set @IsOfficialDealer = null


	if (@BrandId is not null) begin
		
		select 
			d.Id as 'Id',
			d.Name as 'Name',
			d.Email as 'Email',
			d.OfficialName as 'OfficialName',
			d.OfficialEmail as 'OfficialEmail',
			d.DefaultRequestMethod as 'DefaultRequestMethod',
			isnull(d.GoInPurchaseList, 0) as 'GoInPurchaseList', 
			cast ( iif(dfd.DISTRIBUTORID Is Null, 0, 1) as bit)  AS 'IsOffToday',
			d.Active as 'Published',
			isnull(d.GoInAutoControl, 0) as 'GoInAutoControl',
			d.Priority as 'Priority',
			d.DeliveryDaysFrom as 'DeliveryDaysFrom',
			d.DeliveryDaysTo as 'DeliveryDaysTo',
			d.ReturnEnable as 'ReturnEnable',
			d.ReturnEnableState as 'ReturnEnableState',
			d.FIRSTALWAYS as 'FirstAlways',
			d.OfficialDealer as 'OfficialDealer',
			cast(iif((mdl.DistributorId is null), 0, 1) as bit) as 'OfficialDealerForBrand',
			brand.Deleted as 'NowPresent'
		from DISTRIBUTORS d 
			-- связь с брендом
			 join ( select pr.DISID as 'DisId', max(cast(rec.DELETED as int)) as 'Deleted'
						from PRODUCTS p
						join LINKS l on p.Id = l.CATALOGPRODUCTID and p.MANID = @BrandId
						join PRICESRECORDS rec on rec.RECORDINDEX = l.PRICERECORDINDEX
						join PRICES pr on rec.PRICEID = pr.ID
					group by pr.DISID
					) brand on brand.DisId = d.ID
			LEFT JOIN DistributorFreeDays dfd ON d.ID = dfd.DISTRIBUTORID AND dfd.FREEDAY = CAST(getdate() AS date)
			left join (
				select distinct l.DistributorId
				from MainDistributorForBrandLinks l
			) mdl on mdl.DistributorId = d.ID
		where 
			  (@Active is null or  Active = @Active) and
			  (@SendRequestMode is null or (@SendRequestMode is not null and d.SendRequestMode = @SendRequestMode)) and 
			  (@GoInPurchaseList = 0 or d.GoInPurchaseList = @GoInPurchaseList) and 
			  (@GoInAutoControl = 0 or d.GoInAutoControl = @GoInAutoControl) and
			  (@IsOfficialDealer is null or (@IsOfficialDealer is not null and d.OfficialDealer = @IsOfficialDealer)) and
			  (@IsOfficialDealerForBrand is null or (@IsOfficialDealerForBrand is not null and mdl.DistributorId is not null)) and
			  (@Name is null or (@Name is not null and d.Name like '%'+ @Name +'%'))  and
			  (@Email is null or (@Email is not null and d.Email like '%'+ @Email +'%')) 	
		order by 
			d.Name

	end else begin

		select distinct
			d.Id as 'Id',
			d.Name as 'Name',
			isnull(d.Email,'') as 'Email',
			isnull(d.OfficialName,'') as 'OfficialName',
			isnull(d.OfficialEmail,'') as 'OfficialEmail',
			d.DefaultRequestMethod as 'DefaultRequestMethod',
			isnull(d.GoInPurchaseList, 0) as 'GoInPurchaseList', 
			cast ( iif(dfd.DISTRIBUTORID Is Null, 0, 1) as bit) AS 'IsOffToday',
			d.Active as 'Published',
			isnull(d.GoInAutoControl, 0) as 'GoInAutoControl',
			d.Priority as 'Priority',
			d.DeliveryDaysFrom as 'DeliveryDaysFrom',
			d.DeliveryDaysTo as 'DeliveryDaysTo',
			d.ReturnEnable as 'ReturnEnable',
			d.ReturnEnableState as 'ReturnEnableState',
			d.FIRSTALWAYS as 'FirstAlways',
			d.OfficialDealer as 'OfficialDealer',
			cast(iif((mdl.DistributorId is null), 0, 1) as bit) as 'OfficialDealerForBrand',
			null as 'NowPresent'
		from	
			DISTRIBUTORS d 
 			left join DistributorFreeDays dfd ON d.ID = dfd.DISTRIBUTORID AND dfd.FREEDAY = CAST(getdate() AS date)
			left join (
				select distinct l.DistributorId
				from MainDistributorForBrandLinks l
			) mdl on mdl.DistributorId = d.ID
		where 
			(@Active is null or  Active = @Active) and
			(@SendRequestMode is null or (@SendRequestMode is not null and d.SendRequestMode = @SendRequestMode)) and 
			(@GoInPurchaseList = 0 or d.GoInPurchaseList = @GoInPurchaseList) and 
			(@IsGulden = 0 or d.IsGulden = @IsGulden) and 
			(@GoInAutoControl = 0 or d.GoInAutoControl = @GoInAutoControl) and
			(@IsOfficialDealer is null or (@IsOfficialDealer is not null and d.OfficialDealer = @IsOfficialDealer)) and
			(@IsOfficialDealerForBrand is null or (@IsOfficialDealerForBrand is not null and mdl.DistributorId is not null)) and
			(@Name is null or (@Name is not null and d.Name like '%'+ @Name +'%'))  and
			(@Email is null or (@Email is not null and d.Email like '%'+ @Email +'%'))
		order by 
			d.Name

	end

end
