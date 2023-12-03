create proc DistributorsView_v2 (
							   @Name  varchar(255),
							   @Email nvarchar(255),
							   @BrandId uniqueidentifier,
							   @Active bit,
							   @SendRequestMode  int,
							   @GoInPurchaseList bit,
							   @GoInAutoControl  bit
							 ) as
begin


if (@BrandId is not null )	
begin
	SELECT 
	d.Id as 'Id',
	d.Name as 'Name',
	d.Email as 'Email',
	d.OfficialName as 'OfficialName',
	d.OfficialEmail as 'OfficialEmail',
	d.DefaultRequestMethod as 'DefaultRequestMethod',
	d.GoInPurchaseList as 'GoInPurchaseList', 
	cast ( iif(dfd.DISTRIBUTORID Is Null, 0, 1) as bit)  AS 'IsOffToday',
	d.Active as 'Published',
	d.GoInAutoControl as 'GoInAutoControl',
	d.Priority as 'Priority',
	d.DeliveryDaysFrom as 'DeliveryDaysFrom',
	d.DeliveryDaysTo as 'DeliveryDaysTo',
	d.ReturnEnable as 'ReturnEnable',
	d.FIRSTALWAYS as 'FirstAlways',
	cast(
	case 
	    when (count(rec.DELETED) -(sum(cast(rec.DELETED as int)))>0) then 1
		  else 0
    end  as bit ) as 'NowPresent'
	FROM DISTRIBUTORS d 
    join PRICES pr on pr.DISID=d.ID
	join PRICESRECORDS rec on  rec.PRICEID=pr.Id 
	join Links l on l.PRICERECORDINDEX=rec.RECORDINDEX
	join Products p on p.Id=l.CATALOGPRODUCTID
	join MANUFACTURERS m on  m.Id=p.MANID and  m.ID=@BrandId
	LEFT JOIN DistributorFreeDays dfd ON d.ID = dfd.DISTRIBUTORID AND dfd.FREEDAY = CAST(getdate() AS date)
	WHERE 
	      (d.Name like '%'+isnull(@Name,d.Name)+'%')  and
		  (Email like '%'+isnull(@Email,Email)+'%')  and
		  (@Active is null or  Active = @Active) AND 
		  (SendRequestMode = isnull(@SendRequestMode,SendRequestMode)) AND 
		  (GoInPurchaseList = @GoInPurchaseList or @GoInPurchaseList=0) AND 
		  (GoInAutoControl=@GoInAutoControl or @GoInAutoControl=0)
		  group by d.Id, 
	      d.Name,d.Email,d.OfficialName,d.OfficialEmail,d.DefaultRequestMethod,d.GoInPurchaseList, iif(dfd.DISTRIBUTORID Is Null, 0, 1), d.Active,	d.GoInAutoControl,d.Priority,
			 d.DeliveryDaysFrom,d.DeliveryDaysTo,d.ReturnEnable,d.FIRSTALWAYS
	ORDER BY d.NAME
end
else
 begin
 SELECT distinct
	d.Id as 'Id',
	d.Name as 'Name',
	d.Email as 'Email',
	d.OfficialName as 'OfficialName',
	d.OfficialEmail as 'OfficialEmail',
	d.DefaultRequestMethod as 'DefaultRequestMethod',
	d.GoInPurchaseList as 'GoInPurchaseList', 
	cast ( iif(dfd.DISTRIBUTORID Is Null, 0, 1) as bit) AS 'IsOffToday',
	d.Active as 'Published',
	d.GoInAutoControl as 'GoInAutoControl',
	d.Priority as 'Priority',
	d.DeliveryDaysFrom as 'DeliveryDaysFrom',
	d.DeliveryDaysTo as 'DeliveryDaysTo',
	d.ReturnEnable as 'ReturnEnable',
	d.FIRSTALWAYS as 'FirstAlways',
    null as 'NowPresent'
	FROM DISTRIBUTORS d 
 	LEFT JOIN DistributorFreeDays dfd ON d.ID = dfd.DISTRIBUTORID AND dfd.FREEDAY = CAST(getdate() AS date)
	WHERE 
	      (d.Name like '%'+isnull(@Name,d.Name)+'%')  and
		  (Email like '%'+isnull(@Email,Email)+'%')  and
		  (@Active is null or  Active = @Active) AND 
		  (SendRequestMode = isnull(@SendRequestMode,SendRequestMode)) AND 
		  (GoInPurchaseList = @GoInPurchaseList or @GoInPurchaseList=0) AND 
		  (GoInAutoControl=@GoInAutoControl or @GoInAutoControl=0)
	ORDER BY d.NAME
 end

end
