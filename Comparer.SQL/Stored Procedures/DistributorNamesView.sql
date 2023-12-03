create proc DistributorNamesView (@IsActive bit) as
begin

	if @IsActive is null
		select d.ID as 'Id', d.NAME as 'Name' from DISTRIBUTORS d order by d.NAME
	else
		select d.ID as 'Id', d.NAME as 'Name' from DISTRIBUTORS d where d.ACTIVE = @IsActive order by d.NAME
	
end
