create proc DistributorsShortInfo
(
	@IsActive	bit	= NULL
)
 as
 begin

 	select
		d.ID	as 'Id',
		d.NAME	as 'Name',
		/*sum(case 
				when l.PRICERECORDINDEX is not null then 0
				when pr.RECORDINDEX is null then 0
				else 1
			end)*/
		0		as 'NewRecords'
	from DISTRIBUTORS d	
		/*left join Prices p on p.DISID = d.ID
		left join PRICESRECORDS pr on pr.PRICEID = p.Id and pr.DELETED = 0 and pr.USED = 1 and pr.State=1
		left join LINKS l on l.PRICERECORDINDEX = pr.RECORDINDEX*/
	where 
		@IsActive is null or @IsActive is not null and d.ACTIVE = @IsActive
	--group by d.Id, d.Name
	order by d.Name 

end
