create proc GetDistributorsWithNewProducts
(
	@IsActive	bit	= NULL
)
 as
 begin

 	select
		d.ID	as 'Id',
		d.NAME	as 'Name',
		isnull(r.NewRecords,0)
				as 'NewRecords'
	from DISTRIBUTORS d	
		left join (
			select pr.DisID, count(rec.RECORDINDEX) as 'NewRecords'
			from Prices pr
				join PRICESRECORDS rec on pr.Id = rec.PRICEID and rec.DELETED = 0 and rec.USED = 1 and rec.State = 1
			group by pr.DisID
		) r on r.DISID = d.ID
	where 
		@IsActive is null or @IsActive is not null and d.ACTIVE = @IsActive
	order by d.Name 

end
